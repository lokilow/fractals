extern crate num_cpus;
use image::GrayImage;
use num::Complex;
use rustler::NifMap;

#[derive(NifMap)]
struct ComplexNifMap {
    re: f64,
    im: f64,
}

impl ComplexNifMap {
    fn to_complex(&self) -> Complex<f64> {
        Complex {
            re: self.re,
            im: self.im,
        }
    }
}

#[rustler::nif]
fn generate(
    image_size: (usize, usize),
    upper_left_nm: ComplexNifMap,
    lower_right_nm: ComplexNifMap,
) -> Vec<u8> {
    let (width, height) = image_size;
    let upper_left = upper_left_nm.to_complex();
    let lower_right = lower_right_nm.to_complex();

    // count logical cores this process could try to use
    let threads = num_cpus::get();
    let rows_per_band = height / threads + 1;
    let total_pixels = width * height;
    let mut pixels = vec![0; total_pixels];

    let bands: Vec<&mut [u8]> = pixels.chunks_mut(rows_per_band * width).collect();
    crossbeam::scope(|spawner| {
        for (i, band) in bands.into_iter().enumerate() {
            let top = rows_per_band * i;
            let band_height = band.len() / width;
            let band_bounds = (width, band_height);

            let band_upper_left =
                pixel_to_point((width, height), (0, top), upper_left, lower_right);

            let band_lower_right = pixel_to_point(
                (width, height),
                (width, top + band_height),
                upper_left,
                lower_right,
            );

            spawner.spawn(move |_| {
                render(band, band_bounds, band_upper_left, band_lower_right);
            });
        }
    })
    .unwrap();

    let mut buf = Vec::new();
    let encoder = image::codecs::png::PngEncoder::new(&mut buf);

    let img = GrayImage::from_vec(width as u32, height as u32, pixels).unwrap();
    img.write_with_encoder(encoder)
        .expect("could not encode png!");

    buf
}

/// Given the row and column of a  pixel in the output image, return the corresponding point on the complex plane
///
/// `bounds` is a pair giving the width and height of the image in pixels
/// `pixel` is a (column, row) pair indicating a particular pixel in that image
/// The `upper_left` and `lower_right` parameters are points on the complex plane designating the area our image covers
fn pixel_to_point(
    bounds: (usize, usize),
    pixel: (usize, usize),
    upper_left: Complex<f64>,
    lower_right: Complex<f64>,
) -> Complex<f64> {
    let (width, height) = (
        lower_right.re - upper_left.re,
        lower_right.im - upper_left.im,
    );

    Complex {
        re: upper_left.re + pixel.0 as f64 * width / bounds.0 as f64,
        im: upper_left.im + pixel.1 as f64 * height / bounds.1 as f64,
    }
}

#[test]
fn test_pixel_to_point() {
    assert_eq!(
        pixel_to_point(
            (100, 200),
            (25, 175),
            Complex { re: -1.0, im: 1.0 },
            Complex { re: 1.0, im: -1.0 }
        ),
        Complex {
            re: -0.5,
            im: -0.75
        }
    )
}

fn render(
    pixels: &mut [u8],
    bounds: (usize, usize),
    upper_left: Complex<f64>,
    lower_right: Complex<f64>,
) {
    let (width, height) = bounds;
    for row in 0..height {
        for col in 0..width {
            let point = pixel_to_point(bounds, (col, row), upper_left, lower_right);
            let pixel = match escape_time(point, 255) {
                None => 0,
                Some(count) => 255 - count as u8,
            };
            pixels[row * width + col] = pixel;
        }
    }
}

fn escape_time(c: Complex<f64>, limit: usize) -> Option<usize> {
    let mut z = Complex { re: 0.0, im: 0.0 };
    for i in 0..limit {
        // z diverges if its radius is greater than 2
        if z.norm_sqr() > 4.0 {
            return Some(i);
        }
        z = z * z + c
    }
    None
}

rustler::init!("Elixir.Fractals.Generate.Nif");

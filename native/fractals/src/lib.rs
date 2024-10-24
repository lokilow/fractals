use image::{GrayImage, Luma};
use num::Complex;

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
        upper_left.im - lower_right.im,
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

#[rustler::nif]
fn generate() -> Vec<u8> {
    let bounds = (1000, 1000);
    let upper_left = Complex { re: -1., im: 0. };
    let lower_right = Complex { re: 0., im: -1. };

    // render(&mut pixels, bounds, upper_left, lower_right);
    let mut img = GrayImage::new(bounds.0 as u32, bounds.1 as u32);

    for row in 0..bounds.1 {
        for col in 0..bounds.0 {
            let point = pixel_to_point(bounds, (col, row), upper_left, lower_right);
            let pixel = match escape_time(point, 255) {
                None => 0,
                Some(count) => 255 - count as u8,
            };
            img.put_pixel(col as u32, row as u32, Luma::from([pixel]));
        }
    }
    let mut buf = Vec::new();
    let encoder = image::codecs::png::PngEncoder::new(&mut buf);
    img.write_with_encoder(encoder)
        .expect("could not encode png!");
    buf
}

rustler::init!("Elixir.Fractals.Generate");

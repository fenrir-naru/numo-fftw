# frozen_string_literal: true
# port from numru-fftw3/test/complexFFT.rb

require 'rspec'

require "numo/fftw"

module Numo::FFTW
  FORWARD = -1
  BACKWARD = 1
  singleton_methods.each{|func|
    slice = (/(\d)d/ =~ func.to_s) ? $1.to_i : 0
    {:fw => FORWARD, :bk => BACKWARD}.each{|dir, sign|
      define_singleton_method("#{func}_#{dir}".to_sym){|na|
        res = send(func, na, sign)
        (dir == :bk) ? (res / res.shape[-slice..-1].inject(:*)) : res
      }
    }
  }
end

RSpec::describe Numo::FFTW do
  let(:fftw){described_class}
  let(:eps){1e-10}
  let(:seps){1e-6}
  
  it 'can perform forward and backward FFT' do # test_fft_fw_bk
    na = Numo::DFloat::new(8,4).fill(1)  # will be corced to complex
    na[1,1]=5
    fc = fftw.dft_fw(na)
    nb = fftw.dft_bk(fc).real
    expect((na-nb).abs.max).to be < eps

    fc = fftw.dft_1d_fw(na)
    nb = fftw.dft_1d_bk(fc).real
    expect((na-nb).abs.max).to be < eps
  end
  
  it 'can perform real forward FFT' do # test_real_all_dims
    na = Numo::DFloat::new(8,4).fill(1)  # will be corced to complex
    na[1,1]=5
    fc = fftw.dft(na, fftw::FORWARD)/na.length 
    nb = fftw.dft(fc, fftw::BACKWARD).real
    expect((na-nb).abs.max).to be < eps
  end

  it 'can perform complex forward FFT' do # test_complex_all_dims
    na = Numo::DComplex::new(8,4).fill(1) * Complex::I
    na[1,1]=5
    fc = fftw.dft(na, fftw::FORWARD)/na.length 
    nb = fftw.dft(fc, fftw::BACKWARD)
    expect((na-nb).abs.max).to be < eps
  end
  
  it 'can perform single precision forward FFT' do # test_single_float
    # single float (treated as single if lib fftw3f exits).
    # see http://www.fftw.org/fftw3_doc/Precision.html for more info
    na = Numo::SFloat::new(8,4).indgen
    fc = fftw.dft(na, fftw::FORWARD)/na.length 
    nb = fftw.dft(fc, fftw::BACKWARD).real
    expect((na-nb).abs.max).to be < eps
  end
end

__END__
# TODO:
class FFTW3Test < Test::Unit::TestCase
  def test_dim_selection
    na = NArray.float(8,4).indgen!
    fc = FFTW3.fft(na, FFTW3::FORWARD, 0)
    fc = FFTW3.fft(fc, FFTW3::FORWARD, 1)
    fc2 = FFTW3.fft(na, FFTW3::FORWARD)
    assert( (fc-fc2).abs.max < @eps )
  end
end


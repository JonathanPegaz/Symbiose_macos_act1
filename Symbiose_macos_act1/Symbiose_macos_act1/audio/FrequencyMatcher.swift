//
//  FrequencyMatcher.swift
//  Symbiose_macos_act1
//
//  Created by Jonathan Pegaz on 11/01/2023.
//

import Foundation
import AVFoundation
import Accelerate

class FrequencyMatcher: ObservableObject {
    @Published var freqResult:Float = 0.0
    let audioEngine = AVAudioEngine()
    var sampleRate:Float = 44100.0
    var fftSize:Float = 1024.0
    
    func startListening(){
        
        let inputNode = audioEngine.inputNode
        inputNode.installTap( onBus: 0,         // mono input
                              bufferSize: 1000, // a request, not a guarantee
                              format: nil,      // no format translation
                              block: { buffer, when in
            
            // This block will be called over and over for successive buffers
            // of microphone data until you stop() AVAudioEngine
            let actualSampleCount = Int(buffer.frameLength)
            
            // buffer.floatChannelData?.pointee[n] has the data for point n
            var floatBuffer = [Float]()
            var i=0
            
            while (i < actualSampleCount) {
                if let val = buffer.floatChannelData?.pointee[i]{
                    // do something to each sample here...
                    i += 1
                    //print(i)
                    floatBuffer.append(val)
                }
            }
            
            self.extractFFT(floatBuffer)
            
        })
        
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Got an error starting audioEngine: \(error.domain), \(error)")
        }
        
    }
    
    func extractFFT(_ input: [Float]){
        let reals = fft(input).real
        let maxValue = reals.max()!
        if let idx = reals.firstIndex(of: maxValue){
            let fq = frequencyStepForIndex(Float(idx))
            if fq > 10000 && fq < 13000 {
                print("freqmatcher \(fq)")
                self.freqResult = fq
            }
            //print(maxValue)
        }
        
        
    }
    
    func convertUTnt16ToFloat(sampleData:[Int16])->[Float]{
        let numSamples = sampleData.count / MemoryLayout<Int16>.size
        var floats: [Float] = Array(repeating: 0.0, count: numSamples)
        // Int16 array to Float array:
        vDSP_vflt16(sampleData, 1, &floats, 1, vDSP_Length(sampleData.capacity))
        return floats
    }
    
    public func fft(_ input: [Float]) -> (real:[Float], img:[Float]) {
        
        // Input is the real part
        var real = input
        let size = real.count
        
        // prepare a recipient for the Imaginary part (filled with zero by default)
        var imaginary = [Float](repeating: 0.0, count: size)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
        
        // the size has to be a power of 2
        let length = vDSP_Length(floor(log2(Float(size))))
        let radix = FFTRadix(kFFTRadix2)
        let weights = vDSP_create_fftsetup(length, radix)
        
        // perform the FFT
        vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
        
        // clean
        vDSP_destroy_fftsetup(weights)
        
        return (real,imaginary)
    }
    
    public func frequencyStepForIndex(_ index:Float) -> Float {
        return index*sampleRate / fftSize
    }
    
}

public extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

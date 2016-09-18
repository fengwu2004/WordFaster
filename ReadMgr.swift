//
//  ReadMgr.swift
//  WordFaster
//
//  Created by ky on 9/14/16.
//  Copyright © 2016 yellfun. All rights reserved.
//

import Foundation
import AVFoundation

class ReadMgr: NSObject {
    
    var mWords:[WordFaster.Word]
    
    var mIndex:Int
    
    var mSpeechSynthesizer:AVSpeechSynthesizer
    
    init(words:[WordFaster.Word]) {
        
        mWords = words
        
        mIndex = 0
        
        mSpeechSynthesizer = AVSpeechSynthesizer()
        
        super.init()
    }
    
    func startRead() {
        
        mIndex = 0
        
        readWord()
    }
    
    func readWord() {
        
        if mIndex >= mWords.count {
            
            return
        }
        
        let word = mWords[mIndex]
        
        let voice = AVSpeechSynthesisVoice(identifier: "en-US")
        
        let utterance = AVSpeechUtterance(string: word.en)
        
        utterance.voice = voice
        
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        mSpeechSynthesizer.speakUtterance(utterance)
        
        mIndex = mIndex + 1
        
        performSelector(#selector(readWord), withObject: nil, afterDelay: 3)
    }
    
    func stop(Clear clear:Bool) {
        
        mIndex = 0;
        
        if clear {
            
            mWords.removeAll()
        }
        
        mSpeechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
    }
    
    func pause() {
        
        mSpeechSynthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Word)
    }
}
//
//  ViewController.swift
//  MonoChromeStandalone
//
//  Created by mhamilt7 on 21/01/2022.
//

import Cocoa
import OpenGL.GL3

class ViewController: NSViewController {
    
    // This must be implemented
    override public func loadView() {
        //Swift.print("loadView")
        let frameRect = NSRect(x: 0, y: 0,
                               width: 200, height: 200)
        self.view = NSView(frame: frameRect)

        let pixelFormatAttrsBestCase: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFABackingStore),
            UInt32(NSOpenGLPFADepthSize), UInt32(24),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion4_1Core),
            UInt32(0)
        ]
        
        let pf = NSOpenGLPixelFormat(attributes: pixelFormatAttrsBestCase)
        if (pf == nil) {
            fatalError("Couldn't init OpenGL at all, sorry :(")
        }
        let openGLView = SPOpenGLView(frame: frameRect,
                                      pixelFormat: pf)
        self.view.addSubview(openGLView!)
        // Alternatively, instantiating the NSView object could be skipped.
        // In this case, create the NSOpenGLView object and assigned it
        // to the view controller's view property:
        //self.view = openGLView!
    }

    // This will be called when the view (an instance of NSView or its sub-class)
    // is created by the loadView method above.
    override public func viewDidLoad() {
        //Swift.print("viewDidLoad")
        super.viewDidLoad()
        // We can configure the view controller further.
    }
 }


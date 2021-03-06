//
//  GLShader.swift
//
//  Created by Mark Lim Pak Mun on 31/1/15.
//  Copyright (c) 2015 Mark Lim Pak Mun. All rights reserved.
//

/*
 Comments: The shader files are in the Resources subdirectory of the application.
 The file names are expected to consists of only 2 components, the last
 component being considered the file extension.
 Since NSString and String objects can be type-cast to one another, all input/output
 file functions involving the NSString API or any API that requires an NSString
 instance is easily re-written.

 The procedure to compile and link OpenGL shader programs is:
 1) for each shader file, call the method compileShader:shaderType:
    to get a shader ID.
 2)    call the method createAndLinkProgram: to get a program ID using
    the shader IDs obtained from step 1.
*/
import Cocoa
import OpenGL.GL3

// This code can't be moved to a separate source file
// The OpenGL functions were flagged as errors.
public class GLShader
{
    public var program: GLuint = 0

    public init() {
    }
    /*
    Expect the filename of the shader file passed in as a parameter
    consists of exactly 2 components (e.g. vertfrag.vs) and
    is in the Resources subdirectory of the application.
    */
    public func compileShader(filename: String, shaderType: GLenum) -> GLuint {
        let mainBundle = Bundle.main
        let comps = filename.components(separatedBy:".")
        print("\(comps)")
        let shaderPath: String? = mainBundle.path(forResource: comps[0],
                                                  ofType:comps[1])
        if shaderPath == nil {
            print("could not locate the file: \(filename)")
            exit(1)
        }
        //print("shader path:", shaderPath!)
        var shaderID : GLuint = 0

        var source: String?
        do {
            source = try String(contentsOfFile: shaderPath!, encoding: .utf8)
        }
        catch _ {
            print("Failed to load shader:", shaderPath!)
            return 0
        }

        let contents = source!.cString(using: String.Encoding.utf8)
        //print("\(contents)")
        shaderID = glCreateShader(shaderType)
        // problem - glCreateShader is returning 0! - solved. makeCurrentContext() must be called.
        var shaderStringLength = GLint(source!.lengthOfBytes(using: String.Encoding.utf8))

        var cStringPtr = UnsafePointer<GLchar>(contents)
        glShaderSource(shaderID, 1, &cStringPtr, &shaderStringLength)
        glCompileShader(shaderID)
        // But compiling can fail! If we have errors in our GLSL code, we can here and output any errors.
        var compileSuccess: GLint = 0
        glGetShaderiv(shaderID, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if (compileSuccess == GL_FALSE) {
            var logSize: GLint = 0
            glGetShaderiv(shaderID, GLenum(GL_INFO_LOG_LENGTH), &logSize)
            var infoLog: [GLchar] = [GLchar](repeating: 0, count: Int(logSize))
            var infoLogLength: GLsizei = 0
            glGetShaderInfoLog(shaderID, logSize, &infoLogLength, &infoLog)
            let errMsg = String(utf8String: infoLog)
            print("Can't compile:", errMsg!)
            exit(1)
        }
        return shaderID
    }

    // Create and link the shader program using the array of shader IDs
    public func createAndLinkProgram(shaders: [GLuint]) {
        program = glCreateProgram()
        for i in 0..<shaders.count {
            glAttachShader(program, shaders[i])
        }
        glLinkProgram(program)
        // Check for any errors.
        var linkSuccess: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkSuccess)
        if (linkSuccess == GL_FALSE) {
            var logSize: GLint = 0
            glGetProgramiv (program, GLenum(GL_INFO_LOG_LENGTH), &logSize)
            let infoLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logSize))
            glGetProgramInfoLog (program, logSize, nil, infoLog)
            let errMsg = String(utf8String: infoLog)
            print("Failed to create shader program! \(String(describing: errMsg))")
            exit(1)
        }
        for i in 0 ..< shaders.count {
            //glDetachShader(program, shaders[i])
            glDeleteShader(shaders[i])
        }
    }

    public func use() {
        glUseProgram(program)
    }
}

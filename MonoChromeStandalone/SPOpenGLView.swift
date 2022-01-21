
import Cocoa
import OpenGL.GL3

public class SPOpenGLView: NSOpenGLView {
    let shader = GLShader()
    var quadVAO: GLuint = 0
    var stopClock =  Clock()

    // This is required
    public override init?(frame frameRect: NSRect,
                          pixelFormat format: NSOpenGLPixelFormat?) {

        super.init(frame: frameRect, pixelFormat: format)
        let glContext = NSOpenGLContext(format: pixelFormat!,
                                        share: nil)
        //Swift.print("OpenGLView init")
        self.pixelFormat = pixelFormat!
        self.openGLContext = glContext
        //Swift.print(self.openGLContext)
        self.openGLContext!.makeCurrentContext()
    }

    // This is also required
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // This method will be called when the instantiated
    // OpenGL context is made current.
    override public func prepareOpenGL() {
        //Swift.print("prepareOpenGL")
        super.prepareOpenGL()
        // Test to ensure the OpenGL vertex and fragment shaders
        // are compiled into a program.
        var shaderIDs = [GLuint]()
        var shaderID = shader.compileShader(filename: "passthru.vs",
                                            shaderType: GLenum(GL_VERTEX_SHADER))
        shaderIDs.append(shaderID)
        shaderID = shader.compileShader(filename: "passthru.fs",
                                        shaderType: GLenum(GL_FRAGMENT_SHADER))
        shaderIDs.append(shaderID)
        shader.createAndLinkProgram(shaders: shaderIDs)
        // The geometry of the quad is embedded in the vertex shader but
        // OpenGL needs to bind a vertex array object (VAO) before rendering
        glGenVertexArrays(1, &quadVAO)
   }

    // This method is only called once.
    override public func reshape() {
        //Swift.print("reshape")
        super.reshape()
        self.render(elapsedTime: stopClock.timeElapsed())
    }

    // This method is also called once.
    override public func draw(_ _dirtyRect: NSRect) {
        self.render(elapsedTime: stopClock.timeElapsed())
    }

    func render(elapsedTime: Double) {
        //Swift.print("render")
        openGLContext!.makeCurrentContext()
        CGLLockContext(openGLContext!.cglContextObj!)
        glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glViewport(0, 0, GLsizei(frame.width), GLsizei(frame.height))
        // Set the background to gray to indicate the render method had been
        // called in case the shaders are not working properly.
        glClearColor(0.5, 0.5, 0.5, 1.0)

        shader.use()
        glBindVertexArray(quadVAO)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        glBindVertexArray(0)
        glUseProgram(0)

        openGLContext!.update()
        // We're double buffered so need to flush to screen
        openGLContext!.flushBuffer()
        CGLUnlockContext(openGLContext!.cglContextObj!)
    }
}

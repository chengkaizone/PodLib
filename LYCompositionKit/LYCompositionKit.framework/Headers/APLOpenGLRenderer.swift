//
//  APLOpenGLRenderer.swift
//  LYCompositionKit
//
//  Created by tony on 2017/9/10.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import Foundation
import CoreImage
import OpenGLES

struct ShaderCompileError: Error {
    let compileLog: String
}

// 与Shader的通信参数
enum Uniform: GLint {
    
    case from = 0
    case alpha = 1
    case to = 2
    case progress = 3
    case rotationAngle = 4
    case colorConversionMatrix = 5
    case type = 6
    case squaresize = 7
}

enum Attrib: GLuint {
    case vertex = 0
    case textcoord = 1
    case numAttributes = 2
}

enum ShaderType {
    case vertex
    case fragment
}

let quadVertexData: [GLfloat] = [
    -1.0, 1.0,
    1.0, 1.0,
    -1.0, -1.0,
    1.0, -1.0
]

// texture data varies from 0 -> 1, whereas vertex data varies from -1 -> 1
let quadTextureData: [GLfloat] = [
    0.5 + quadVertexData[0] / 2, 0.5 + quadVertexData[1] / 2,
    0.5 + quadVertexData[2] / 2, 0.5 + quadVertexData[3] / 2,
    0.5 + quadVertexData[4] / 2, 0.5 + quadVertexData[5] / 2,
    0.5 + quadVertexData[6] / 2, 0.5 + quadVertexData[7] / 2,
]

/// OpenGLES渲染器
class APLOpenGLRenderer: NSObject {
    
    class func shared() -> APLOpenGLRenderer {
        struct Static {
            static let instance = APLOpenGLRenderer()
        }
        return Static.instance
    }
    
    // 可变数组
    var uniforms = [Uniform: GLint]()
    
    var program: GLuint!
    var vertexShader: GLuint!
    var fragmentShader: GLuint!
    
    // 需要自己管理内存
    lazy var videoTextureCache:CVOpenGLESTextureCache = {
        var newTextureCache:CVOpenGLESTextureCache? = nil
        let err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.currentContext, nil, &newTextureCache)
        return newTextureCache!
    }()
    var currentContext: EAGLContext!
    // 未使用到
    var offscreenBufferHandle: GLuint! = 0
    
    override init() {
        super.init()
        // iOS版本    OpenGL ES版本
        // 2.x    1.x
        // 3.0~6.x    2.x
        // 7.0    3.x
        self.currentContext = EAGLContext(api: EAGLRenderingAPI.openGLES3)
        EAGLContext.setCurrent(self.currentContext)
        
        self.setupOffscreenRenderContext()
        do {
            try self.setupShader()
        } catch let error {
            NSLog("setup shader error \(error)")
        }
        
        EAGLContext.setCurrent(nil)
    }
    
    deinit {
        debugPrint("Shader deallocated")
        
        if (vertexShader != nil) {
            glDeleteShader(vertexShader)
        }
        if (fragmentShader != nil) {
            glDeleteShader(fragmentShader)
        }
        if offscreenBufferHandle != nil {
            glDeleteShader(offscreenBufferHandle)
        }
        
        glDeleteProgram(program)
    }
    
    // 初始化离屏渲染上下文
    private func setupOffscreenRenderContext() {
        glDisable(GLenum(GL_DEPTH_TEST))
        glGenFramebuffers(1, &(self.offscreenBufferHandle))
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.offscreenBufferHandle)
        
        NSLog("screenBufferHander \(self.offscreenBufferHandle)")
    }
    
    // 获取纹理
    func sourceTextureForPixelBuffer(pixelBuffer: CVPixelBuffer) ->CVOpenGLESTexture? {
        
        // Periodic texture cache flush every frame
        CVOpenGLESTextureCacheFlush(videoTextureCache, 0)
        
        // CVOpenGLTextureCacheCreateTextureFromImage will create GL texture optimally from CVPixelBufferRef
        var rgbTexture: CVOpenGLESTexture? = nil
        let err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, videoTextureCache, pixelBuffer, nil, GLenum(GL_TEXTURE_2D), GL_RGBA, GLsizei(CVPixelBufferGetWidth(pixelBuffer)), GLsizei(CVPixelBufferGetHeight(pixelBuffer)), GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), 0, &rgbTexture)
        
        if rgbTexture == nil || err != 0 {
            NSLog("Error at creating rgb texture using CVOpenGLESTextureCacheCreateTextureFromImage \(err)")
            return nil
        }
        return rgbTexture!
    }
    
    // 渲染像素缓冲
    func renderPixelBuffer(destinationPixelBuffer: CVPixelBuffer, foregroundPixelBuffer: CVPixelBuffer?, backgroundPixelBuffer: CVPixelBuffer?, tweenFactor: Float, transitionType: TransitionType) {
        
        EAGLContext.setCurrent(self.currentContext)
        defer {
            CVOpenGLESTextureCacheFlush(self.videoTextureCache, 0)
            EAGLContext.setCurrent(nil)
        }
        guard let foregroundPixelBuffer = foregroundPixelBuffer, let backgroundPixelBuffer = backgroundPixelBuffer else {
            return
        }
        guard let foregroundTexture = self.sourceTextureForPixelBuffer(pixelBuffer: foregroundPixelBuffer) else {
            return
        }
        guard let backgroundTexture = self.sourceTextureForPixelBuffer(pixelBuffer: backgroundPixelBuffer) else {
            return
        }
        guard let destTexture = self.sourceTextureForPixelBuffer(pixelBuffer: destinationPixelBuffer) else {
            return
        }
        
        glViewport(0, 0, GLsizei(CVPixelBufferGetWidth(destinationPixelBuffer)), GLsizei(CVPixelBufferGetHeight(destinationPixelBuffer)))
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(CVOpenGLESTextureGetTarget(foregroundTexture), CVOpenGLESTextureGetName(foregroundTexture))
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
        
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(CVOpenGLESTextureGetTarget(backgroundTexture), CVOpenGLESTextureGetName(backgroundTexture))
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
        
        // attach the desination texture as a color a attachment to the off screen frame buffer
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture), 0)
        
        let status: GLenum = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GL_FRAMEBUFFER_COMPLETE {
            NSLog("Failed to make complete framebuffer object \(status)")
            return
        }
        
        glClearColor(0, 0, 0, 0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUseProgram(self.program)
        
        if transitionType == .pixelize {
            glUniform1f(uniforms[Uniform.squaresize]!, 100)
        }
        
        NSLog("type ---> \(transitionType), tewwn ----> \(tweenFactor)")
        glUniform1i(uniforms[Uniform.from]!, 0)
        glUniform1i(uniforms[Uniform.to]!, 1)
        glUniform1f(uniforms[Uniform.alpha]!, 1.0 - tweenFactor)
        glUniform1i(uniforms[Uniform.type]!, transitionType.rawValue)
        glUniform1f(uniforms[Uniform.progress]!, tweenFactor)
        
        glVertexAttribPointer(Attrib.vertex.rawValue, 2, GLenum(GL_FLOAT), 0, 0, quadVertexData)
        glEnableVertexAttribArray(Attrib.vertex.rawValue)
        glVertexAttribPointer(Attrib.textcoord.rawValue, 2, GLenum(GL_FLOAT), 0, 0, quadTextureData)
        glEnableVertexAttribArray(Attrib.textcoord.rawValue)
        // Blend function to draw the foreground frame
        //glEnable(GLenum(GL_BLEND))
        //glBlendFunc(GLenum(GL_ONE), GLenum(GL_ZERO))
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        glFlush()
    }
    
    /**
     * 初始化Shader相关配置
     */
    private func setupShader() throws {
        // Create the shader program
        self.program = glCreateProgram()
        self.vertexShader = try compileShader(shaderString: VERTEX_SHADER, type: .vertex)
        self.fragmentShader = try compileShader(shaderString: FRAGMENT_SHADER, type: .fragment)
        
        NSLog("vertexShader \(vertexShader)  fragmentShader \(fragmentShader)")
        // Attach vertex shader to programY
        glAttachShader(program, vertexShader)
        // Attach fragment shader to programY
        glAttachShader(program, fragmentShader)
        
        // 关联shader中的参数
        // Bind attribute locations. This needs to be done prior to linking.
        glBindAttribLocation(program, Attrib.vertex.rawValue, "position")
        glBindAttribLocation(program, Attrib.textcoord.rawValue, "texCoord")
        
        do {
            try link()
        } catch let error {
            NSLog("link program error \(error)")
        }
        
        uniforms[.from] = glGetUniformLocation(program, "from")
        uniforms[.to] = glGetUniformLocation(program, "to")
        uniforms[.rotationAngle] = glGetUniformLocation(program, "preferredRotation")
        uniforms[.colorConversionMatrix] = glGetUniformLocation(program, "colorConversionMatrix")
        uniforms[.type] = glGetUniformLocation(program, "type")
        uniforms[.alpha] = glGetUniformLocation(program, "alpha")
        uniforms[.progress] = glGetUniformLocation(program, "progress")
        uniforms[.squaresize] = glGetUniformLocation(program, "squareSizeFactor")
    }
    
    // 编译shader程序
    private func compileShader(shaderString: String, type: ShaderType) throws ->GLuint {
        
        guard shaderString != "" else {
            NSLog("Failed to load vertex shader: Empty source string")
            return GLuint(0)
        }
        print("compile shader--->\(type)  \(shaderString)")
        let shaderHandle: GLuint
        switch type {
        case .vertex: shaderHandle = glCreateShader(GLenum(GL_VERTEX_SHADER))
        case .fragment: shaderHandle = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        }
        
        shaderString.withGLChar { (glString: UnsafePointer<GLchar>) in
            var tempString: UnsafePointer<GLchar>? = glString
            glShaderSource(shaderHandle, GLsizei(1), &tempString, nil)
            glCompileShader(shaderHandle)
        }
        
        var compileStatus:GLint = 1
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
        if (compileStatus != 1) {
            var logLength:GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if (logLength > 0) {
                var compileLog = [CChar](repeating:0, count:Int(logLength))
                glGetShaderInfoLog(shaderHandle, logLength, &logLength, &compileLog)
                print("Compile log: \(String(cString:compileLog))")
                // let compileLogString = String(bytes:compileLog.map{UInt8($0)}, encoding:NSASCIIStringEncoding)
                switch type {
                case .vertex: throw ShaderCompileError(compileLog: "Vertex shader compile error:")
                case .fragment: throw ShaderCompileError(compileLog: "Fragment shader compile error:")
                }
            }
        } else if compileStatus == 0 {
            //glDeleteShader(shaderHandle)
        }
        
        return shaderHandle
    }
    
    func link() throws {
        glLinkProgram(program)
        
        var linkStatus:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if (linkStatus == 0) {
            var logLength:GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if (logLength > 0) {
                var compileLog = [CChar](repeating:0, count:Int(logLength))
                
                glGetProgramInfoLog(program, logLength, &logLength, &compileLog)
                print("Link log: \(String(cString:compileLog))")
            }
            
            throw ShaderCompileError(compileLog:"Link error")
        }
    }
    
}

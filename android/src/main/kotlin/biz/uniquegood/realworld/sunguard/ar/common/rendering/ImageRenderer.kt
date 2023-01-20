package biz.uniquegood.realworld.sunguard.ar.common.rendering

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.opengl.GLES20
import android.opengl.GLUtils
import android.opengl.Matrix
import android.util.DisplayMetrics
import android.util.Log
import java.io.IOException
import java.io.InputStream
import java.lang.Exception
import java.lang.RuntimeException
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

/*
Copyright 2017 Google Inc.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    https://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */

class ImageRenderer {
    private val textures = IntArray(1)
    private lateinit var quadCoords: FloatBuffer
    private lateinit var quadTexCoords: FloatBuffer
    private var program = 0

    // Shader Attribute
    private var positionAttrib = 0
    private var texCoordAttrib = 0
    private var textureUniform = 0
    private var modelViewUniform = 0
    private var modelViewProjectionUniform = 0

    // Temporary matrices allocated here to reduce number of allocations for each frame.
    private val modelMatrix = FloatArray(16)
    private val modelViewMatrix = FloatArray(16)
    private val modelViewProjectionMatrix = FloatArray(16)
    var displayMetrics: DisplayMetrics? = null

    fun createOnGlThread(context: Context, stream: InputStream?) {
        // Read the texture.
        val bitmap: Bitmap
        try {
            bitmap = BitmapFactory.decodeStream(stream)
            createOnGlThread(context, bitmap)
        } catch (e: Exception) {
            Log.e(TAG, "Exception reading texture", e)
            return
        }
        bitmap.recycle()
    }

    fun createOnGlThread(context: Context, img: ByteArray) {
        // Read the texture.
        val bitmap: Bitmap
        try {
            bitmap = BitmapFactory.decodeByteArray(img, 0, img.size)
            createOnGlThread(context, bitmap)
        } catch (e: Exception) {
            Log.e(TAG, "Exception reading texture", e)
            return
        }
        bitmap.recycle()
    }

    @Throws(IOException::class)
    fun createOnGlThread(context: Context, bitmap: Bitmap) {
        val tmpBitmap = bitmap.copy(Bitmap.Config.ARGB_8888, false)
        displayMetrics = context.resources.displayMetrics

        // GLES20.GL_TEXTURE0 에 새로운 텍스쳐 생성
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glGenTextures(textures.size, textures, 0)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textures[0])
        // 텍스쳐 wrapping/filtering 옵션 설정(현재 바인딩된 텍스처 객체에 대해)
        GLES20.glTexParameteri(
            GLES20.GL_TEXTURE_2D,
            GLES20.GL_TEXTURE_WRAP_S,
            GLES20.GL_CLAMP_TO_EDGE
        )
        GLES20.glTexParameteri(
            GLES20.GL_TEXTURE_2D,
            GLES20.GL_TEXTURE_WRAP_T,
            GLES20.GL_CLAMP_TO_EDGE
        )
        GLES20.glTexParameteri(
            GLES20.GL_TEXTURE_2D,
            GLES20.GL_TEXTURE_MIN_FILTER,
            GLES20.GL_NEAREST
        )
        GLES20.glTexParameteri(
            GLES20.GL_TEXTURE_2D,
            GLES20.GL_TEXTURE_MAG_FILTER,
            GLES20.GL_NEAREST
        )
        // 텍스쳐 바인딩
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, tmpBitmap, 0)
        // 비트맵 제거
        tmpBitmap.recycle()
        ShaderUtil.checkGLError(TAG, "Texture loading")

        // Build the geometry of a simple quad.
        val numVertices = 4
        if (numVertices != QUAD_COORDS.size / COORDS_PER_VERTEX) {
            throw RuntimeException("Unexpected number of vertices in BackgroundRenderer.")
        }
        val bbCoords = ByteBuffer.allocateDirect(QUAD_COORDS.size * java.lang.Float.BYTES)
        bbCoords.order(ByteOrder.nativeOrder())
        quadCoords = bbCoords.asFloatBuffer()
        quadCoords.put(QUAD_COORDS)
        quadCoords.position(0)
        val bbTexCoordsTransformed =
            ByteBuffer.allocateDirect(numVertices * TEXCOORDS_PER_VERTEX * java.lang.Float.BYTES)
        bbTexCoordsTransformed.order(ByteOrder.nativeOrder())
        quadTexCoords = bbTexCoordsTransformed.asFloatBuffer()
        quadTexCoords.put(QUAD_TEXCOORDS)
        quadTexCoords.position(0)

        val vertShader =
            ShaderUtil.loadGLShader(TAG, context, GLES20.GL_VERTEX_SHADER, VERT_SHADER)
        val fragShader =
            ShaderUtil.loadGLShader(TAG, context, GLES20.GL_FRAGMENT_SHADER, FRAG_SHADER)
        program = GLES20.glCreateProgram()
        GLES20.glAttachShader(program, vertShader)
        GLES20.glAttachShader(program, fragShader)
        GLES20.glLinkProgram(program)
        GLES20.glUseProgram(program)
        ShaderUtil.checkGLError(TAG, "Program creation")
        positionAttrib = GLES20.glGetAttribLocation(program, "a_Position")
        texCoordAttrib = GLES20.glGetAttribLocation(program, "a_TexCoord")
        textureUniform = GLES20.glGetUniformLocation(program, "u_Texture")
        modelViewUniform = GLES20.glGetUniformLocation(program, "u_ModelView")
        modelViewProjectionUniform =
            GLES20.glGetUniformLocation(program, "u_ModelViewProjection")
        ShaderUtil.checkGLError(TAG, "Program parameters")
    }

    fun updateModelMatrix(modelMatrix: FloatArray?, extendX: Float, extendY: Float) {
        val scaleMatrix = FloatArray(16)
        Matrix.setIdentityM(scaleMatrix, 0)
        scaleMatrix[0] = 0.0f
        scaleMatrix[5] = 0.0f
        scaleMatrix[10] = 0.0f
        Matrix.setRotateM(scaleMatrix, 0, -90.0f, 1.0f, 0.0f, 0.0f)
        Matrix.multiplyMM(this.modelMatrix, 0, modelMatrix, 0, scaleMatrix, 0)
        Matrix.rotateM(this.modelMatrix, 0, 180.0f, 0.0f, 1.0f, 0f)
        Matrix.rotateM(this.modelMatrix, 0, -90.0f, 0.0f, 0.0f, 1.0f)
        Matrix.scaleM(this.modelMatrix, 0, -(extendY * 0.5f), -(extendX * 0.5f), 0.0f)
    }

    fun draw(cameraView: FloatArray?, cameraPerspective: FloatArray?) {
        ShaderUtil.checkGLError(TAG, "Before draw")
        Matrix.multiplyMM(modelViewMatrix, 0, cameraView, 0, modelMatrix, 0)
        Matrix.multiplyMM(modelViewProjectionMatrix, 0, cameraPerspective, 0, modelViewMatrix, 0)
        GLES20.glUseProgram(program)

        // Attach the object texture.
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textures[0])
        GLES20.glUniform1i(textureUniform, 0)

        // Set the ModelViewProjection matrix in the shader.
        GLES20.glUniformMatrix4fv(modelViewUniform, 1, false, modelViewMatrix, 0)
        GLES20.glUniformMatrix4fv(
            modelViewProjectionUniform,
            1,
            false,
            modelViewProjectionMatrix,
            0
        )

        // Set the vertex positions.
        GLES20.glVertexAttribPointer(
            positionAttrib,
            COORDS_PER_VERTEX,
            GLES20.GL_FLOAT,
            false,
            0,
            quadCoords
        )

        // Set the texture coordinates.
        GLES20.glVertexAttribPointer(
            texCoordAttrib,
            TEXCOORDS_PER_VERTEX,
            GLES20.GL_FLOAT,
            false,
            0,
            quadTexCoords
        )

        // Set the ModelViewProjection matrix in the shader.
        GLES20.glUniformMatrix4fv(modelViewUniform, 1, false, modelViewMatrix, 0)
        GLES20.glUniformMatrix4fv(
            modelViewProjectionUniform,
            1,
            false,
            modelViewProjectionMatrix,
            0
        )

        // Alpha 값 제거
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA)

        // Enable vertex arrays
        GLES20.glEnableVertexAttribArray(positionAttrib)
        GLES20.glEnableVertexAttribArray(texCoordAttrib)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
        GLES20.glDisable(GLES20.GL_BLEND)

        // Disable vertex arrays
        GLES20.glDisableVertexAttribArray(positionAttrib)
        GLES20.glDisableVertexAttribArray(texCoordAttrib)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0)
        ShaderUtil.checkGLError(TAG, "After draw")
    }

    companion object {
        private const val TAG = "BitmapsRenderer"
        //    int[] textures;
        /**
         * (-1, 1) ------- (1, 1)
         * |    \           |
         * |       \        |
         * |          \     |
         * |             \  |
         * (-1, -1) ------ (1, -1)
         * Ensure triangles are front-facing, to support glCullFace().
         * This quad will be drawn using GL_TRIANGLE_STRIP which draws two
         * triangles: v0->v1->v2, then v2->v1->v3.
         */
        private val QUAD_COORDS =
            floatArrayOf(-1.0f, -1.0f, +1.0f, -1.0f, -1.0f, +1.0f, +1.0f, +1.0f)
        private val QUAD_TEXCOORDS = floatArrayOf( // x, y
            0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f
        )
        private const val COORDS_PER_VERTEX = 2
        private const val TEXCOORDS_PER_VERTEX = 2

        // Shader source code, since they are small, just include them inline.
        private const val VERT_SHADER = "shaders/default.vert"
        private const val FRAG_SHADER = "shaders/default.frag"
    }
}
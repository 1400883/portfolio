/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
Shader "Custom/2 Luminance-Brightness-Contrast-Gamma" {
  Properties {
    [HideInInspector]
    _MainTex ("Texture", 2D) = "white" {}

    [Toggle] _GrayscaleEnable ("Enable grayscaling", Range(0, 1)) = 0.0
    _Brightness ("Brightness", Range(-1, 2)) = 0.0
    _Contrast ("Contrast", Range(-1, 1)) = 0.0
    _Gamma ("Gamma Correction", Range(-1, 2)) = 0.0
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 200
    Pass {
      GLSLPROGRAM
        varying vec2 texCoord;

        // Vertex shader
        #ifdef VERTEX
          void main()
          {
            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            texCoord = gl_MultiTexCoord0.xy;
          }
        #endif

        // Fragment shader
        #ifdef FRAGMENT
          uniform sampler2D _MainTex;
          uniform float _GrayscaleEnable;
          uniform float _Brightness;
          uniform float _Contrast;
          uniform float _Gamma;

          vec4 GetPixel(vec2 pos) {
            return texture2D(_MainTex, pos);
          }

          vec4 ConvertToGrayscale(vec4 color) {
            float average = (color.r + color.g + color.b) / 3.0;
            return vec4(average);
          }

          vec4 AdjustContrast(vec4 color, float adjustRatio) {
            const float constant = 1.0156863; // 259/255
            float factor = constant * (adjustRatio + 1.0) / (constant - adjustRatio);
            return clamp(factor * (color - 0.5) + 0.5, 0.0, 1.0);
          }

          vec4 AdjustBrightness(vec4 color, float adjustRatio) {
            return color * (adjustRatio + 1.0);
          }

          vec4 AdjustGammaCorrection(vec4 color, float adjustRatio) {
            return pow(color, vec4(1.0 / (adjustRatio + 1.0)));
          }

          void main()
          {
            vec4 color = GetPixel(texCoord);

            gl_FragColor = color;
            
            // COLOR TO GRAYSCALE
            gl_FragColor = (1.0 - _GrayscaleEnable) * gl_FragColor + 
              _GrayscaleEnable * ConvertToGrayscale(gl_FragColor);

            // CONTRAST
            gl_FragColor = AdjustContrast(gl_FragColor, _Contrast);

            // BRIGHTNESS
            gl_FragColor = AdjustBrightness(gl_FragColor, _Brightness);

            // GAMMA
            gl_FragColor = AdjustGammaCorrection(gl_FragColor, _Gamma);
          }
        #endif

      ENDGLSL
    }
  } 
  FallBack "Diffuse"
}

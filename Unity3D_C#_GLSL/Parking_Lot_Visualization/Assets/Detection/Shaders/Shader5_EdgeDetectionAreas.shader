/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
Shader "Custom/5 Edge detection areas" {
  Properties {
    [HideInInspector]
    _MainTex ("Texture", 2D) = "white" {}
    _ColorTex ("Texture", 2D) = "white" {}
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 200
    Pass {
      GLSLPROGRAM
        varying lowp vec2 texCoord;

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
          uniform lowp sampler2D _MainTex;
          // Texture that contains interpolated detection 
          // area cornerpoint locations as color data
          uniform lowp sampler2D _ColorTex;
          // Main texture aspect, used to compensate for X/Y 
          // difference in drawing square-shaped cornerpoints 
          uniform lowp float _MainTexAspectRatio;
          // This needs to be passed from the app to ensure once drawn
          // cornerpoints are erased during play mode when the user 
          // unselects the option in the inspector
          uniform lowp float _DisplayCornerpoints;
          // Cornerpoint location texture dimensions
          uniform lowp int _ColorTexWidth;
          uniform lowp int _ColorTexHeight;
          uniform lowp vec4 _CornerColor0;
          uniform lowp vec4 _CornerColor1;
          // The (approximate) size of the visible corner point.
          uniform lowp float _CornerpointRadius;
          // Use two alternating colors to display parking slot detection areas. 
          // This makes for easier distinction between adjacent parking slots.
          lowp vec4 cornerColors[2];

          // See IsEqual() comments
          const lowp float roundComp = 0.0015;

          vec4 GetPixel(vec2 pos, sampler2D texture) {
            return texture2D(texture, pos);
          }

          // IsEqual compares interpolated X and Y coordinates. Fragment 
          // coordinates are compared with the cornerpoint coordinates extracted 
          // from color texture. The result tells if the fragment being processed 
          // is located on a cornerpoint and should thus be colored accordingly.
          float IsEqual(float a, float b, float vertAspectCompensation) {
            // roundComp value used as base tolerance is a result of simple trial
            // & error. Tolerance is required due to floating point rounding errors,
            // i.e., storing the interpolated cornerpoint location in a float variable
            // in the application results in lost precision, which is compensated here.
            return  step(b - roundComp * _CornerpointRadius * vertAspectCompensation, a) *
                    step(a, b + roundComp * _CornerpointRadius * vertAspectCompensation);
          }

          void main()
          {
            // Two alternating colors
            cornerColors[0] = _CornerColor0;
            cornerColors[1] = _CornerColor1;

            lowp vec4 color = GetPixel(texCoord, _MainTex);
            
            // Go through the cornerpoint data texture passed from the app
            for (int row = 0; row < 100; ++row) {
              if (row == _ColorTexHeight) { break; }
            // for (int row = 0; row < _ColorTexHeight; ++row) {
              for (int col = 0; col < 100; ++col) {
                if (col == _ColorTexWidth) { break; }
              // for (int col = 0; col < _ColorTexWidth; ++col) {
                // Each RGBA pixel in the supplied texture contains data for 
                // two cornerpoint coordinates. One slot consists of a total
                // of four cornerpoints, so every consecutive pair of pixels
                // matching a cornerpoint location should be colored using 
                // the same color.

                // RGBA pixel (== cornerpoint pair) index value
                lowp int index = row * _ColorTexWidth + col;
                // Integer value that denotes the index of 2 RGBA pixels
                // (== 4 cornerpoints == one complete parking slot area)
                lowp int whole = index / 2;
                // Modulus by 2 gives array-compatible index for alternating
                // between two colors
                lowp float modulus = mod(float(whole), 2.0);
                // Get the actual color data (== interpolated cornerpoint 
                // pair location) from the supplied texture.
                // NOTE: ALWAYS get the interpolated center point of the pixel
                // to avoid floating point rounding error hell.
                lowp vec4 posColor = GetPixel(vec2(
                  (float(col) + 0.5) / float(_ColorTexWidth), 
                  (float(row) + 0.5) / float(_ColorTexHeight)), _ColorTex);
                // Determine whether the fragment location matches a location of 
                // either cornerpoint extracted from the texture. Result will be
                // a 'binary float', 0.0 for false, 1.0 for true. max() equals 
                // conditional OR, multiplication equals conditional AND.

                // Pass aspect ratio for Y coordinate to compensate for difference 
                // in how far _pixel-wise_ the equality test "reaches out", between
                // horizontal and vertical dimensions, to determine if fragment
                // location matches cornerpoint location.
                // This is due to the likely difference between main texture 
                // horizontal / vertical dimensions, that when interpolated, will 
                // result in unequal pixel count (usually horizontal distance is
                // greater than vertical, aspect ratio > 1). Finally, multiply by 
                // display variable to set/clear cornerpoint colors to/from the image.
                lowp float binaryRatio = max(
                  IsEqual(texCoord.x, posColor.r, 1.0) * IsEqual(texCoord.y, posColor.g, _MainTexAspectRatio),
                  IsEqual(texCoord.x, posColor.b, 1.0) * IsEqual(texCoord.y, posColor.a, _MainTexAspectRatio)) *
                  _DisplayCornerpoints;

                // Apply the result to produce either a statically colored fragment 
                // (cornerpoint location) or original source texture pixel color
                // color = binaryRatio * _Color + (1.0 - binaryRatio) * color;
                // color = binaryRatio * vec4(1.0, 0.0, 0.0, 1.0) + (1.0 - binaryRatio) * color;
                color = binaryRatio * ((1.0 - modulus) * _CornerColor0 + modulus * _CornerColor1) + (1.0 - binaryRatio) * color;
              }
            }
            // NOTE: For debugging - do not remove
            // gl_FragColor = GetPixel(texCoord, _ColorTex);
            gl_FragColor = color;
          }
        #endif
      ENDGLSL
    }
  } 
  FallBack "Diffuse"
}

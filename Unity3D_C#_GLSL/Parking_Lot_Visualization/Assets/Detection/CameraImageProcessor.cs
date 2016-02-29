/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class CameraImageProcessor : MonoBehaviour {
  public Material material2_LuminanceBrightnessContrastGamma;
  public Material material3_GaussianBlur;
  public Material material4_SobelEdgeDetection;
  public Material material5_EdgeDetectionAreas;

  DetectionAreaDisplay daDisplay;
  PlaneManager planeManager;
  
  List<Material> needSourceSizeMaterials;
  RenderTexture[] rTextures;

  void Awake() {
    planeManager = transform.parent.parent.GetChild(1).GetComponent<PlaneManager>();
    daDisplay = transform.parent.GetChild(transform.parent.childCount - 1).
      GetComponent<DetectionAreaDisplay>();
  }

  void Start() {
    needSourceSizeMaterials = new List<Material>();

    //////////////////////////////////////////////////////
    // Add new materials that require source dimensions here!
    //////////////////////////////////////////////////////
    needSourceSizeMaterials.Add(material3_GaussianBlur);
    needSourceSizeMaterials.Add(material4_SobelEdgeDetection);

    // Temporary rendertextures for processing planes
    rTextures = new RenderTexture[4];
  }

  void OnRenderImage(RenderTexture src, RenderTexture dest) {
    // Setup data for detection area cornerpoint 
    // display to be sent to the shader;
    daDisplay.SetCornerpointDisplayData(material5_EdgeDetectionAreas);
    
    // Due to initial first network source image delay on playback start,
    // a dummy texture of arbitrary size has been created to provide
    // valid data to scripts that depend on a non-zero sized source 
    // texture. Because the size of the network image, once it arrives,
    // may be different from initial texture size, the size info needs
    // to be resent to shaders and processing plane rendertextures 
    // recreated in correct dimensions.

    // Pass source texture dimensions to materials whose shaders need the info
    foreach (Material m in needSourceSizeMaterials) {
      m.SetFloat("_tWidth", (float)planeManager.GetSourceWidth());
      m.SetFloat("_tHeight", (float)planeManager.GetSourceHeight());
    }

    // Create and assign temporary rendertextures. 
    // Fortunately, there's little overhead.
    for (int iTex = 0; iTex < rTextures.Length; ++iTex) {

      rTextures[iTex] = RenderTexture.GetTemporary(
        planeManager.GetSourceWidth(), 
        planeManager.GetSourceHeight());

      transform.parent.parent.GetChild(1).GetChild((iTex + 1) * 2 + 1).
        GetChild(0).GetComponent<Renderer>().material.mainTexture = rTextures[iTex];
    }
    
    // Shader pass 1
    // Luminance-Brightness-Contrast-Gamma blitting
    ////////////////////////////////////////////////
    Graphics.Blit(
      src, 
      rTextures[0], 
      material2_LuminanceBrightnessContrastGamma);

    // Shader pass 2
    // Gaussian blur blitting
    ////////////////////////////////////////////////
    Graphics.Blit(
      rTextures[0], 
      rTextures[1], 
      material3_GaussianBlur);

    // Shader pass 3
    // Sobel edge detection
    ////////////////////////////////////////////////
    Graphics.Blit(
      rTextures[1], 
      rTextures[2], 
      material4_SobelEdgeDetection);

    // Shader 
    // Edge detection areas
    ////////////////////////////////////////////////
    Graphics.Blit(
      rTextures[2], 
      rTextures[3],
      material5_EdgeDetectionAreas);

    // Temporary rendertexture cleanup
    foreach (RenderTexture rt in rTextures) {
      RenderTexture.ReleaseTemporary(rt);
    }
    
    // Must Blit to screen as well, or OnGUI content won't display
    Graphics.Blit(src, (RenderTexture)null);
  }
}

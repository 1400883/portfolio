/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class DetectionAreaDisplay : MonoBehaviour {

  public bool displayEdgeDetectionAreas;
  public float edgeCornerPointDisplayRadius;
  public Color cornerPointColorA;
  public Color cornerPointColorB;

  const int texturePixelsPerLine = 2;
  
  ImageSlotExtractor imageSlotExtractor;
  PlaneManager planeManager;
  SlotScript slotScript;

  Texture2D tex;
  List<Color> colorList;
  List<SlotData.Cornerpoint> cpList;

  bool hasWarningBeenIssued;

  void Awake() {
    planeManager = transform.parent.parent.GetChild(1).GetComponent<PlaneManager>();
    slotScript = transform.parent.parent.GetComponent<SlotScript>();
    imageSlotExtractor = transform.parent.parent.
      parent.GetComponent<ImageSlotExtractor>();
  }

  void Start () { hasWarningBeenIssued = false; }

  public void SetCornerpointDisplayData(Material shaderMaterial) {
    cpList = new List<SlotData.Cornerpoint>();
    colorList = new List<Color>();

    if (displayEdgeDetectionAreas)
    {
      // Edge detection cornerpoints have been selected to show up in the inspector

      if (slotScript.slotData.numberOfRows == 0)
      {
        if (!hasWarningBeenIssued) {
          Debug.LogWarning("No detection area rows defined for " + 
            transform.parent.parent.name + ".");
          // Limit warnings to one per each playback
          hasWarningBeenIssued = true;
        }
        return;
      }

      // Get corner points for each area
      for (int iRow = 0; iRow < slotScript.slotData.numberOfRows; ++iRow)
      {
        SlotData.Row row = slotScript.slotData.rows[iRow];
        for (int iSlot = 0; iSlot < row.numberOfSlots; ++iSlot)
        {
          if (row.slots[iSlot].IsUndefined())
            // Unset slot coordinates => skip
            continue;
          cpList.AddRange(row.slots[iSlot].areaCornerpoints);
        }
      }

      // Use texture to pass corner point data to the shader
      //////////////////////////////////////////////////////

      // 4 corner points for each defined slot
      // Each pixel value in texture can hold data for two points,
      // (== half a slot), i.e., sizeof(RGBA) == 2 * sizeof(XY).
      // Therefore, each slot will consume two pixels.
      
      // Slot N (Tex line N)  Tex px N  Px cpnts  Slot cornerpoints
      // 0                    0         RG        (X, Y)
      // 0                    0         BA        (X, Y)
      // 0                    1         RG        (X, Y)
      // 0                    1         BA        (X, Y)
      // -----------------------------------------------
      // 1                    2         RG        (X, Y)
      // 1                    2         BA        (X, Y)
      // 1                    3         RG        (X, Y)
      // 1                    3         BA        (X, Y)
      // -----------------------------------------------
      
      // etc.
      
      // Total number of slots in all parking rows
      int numSlotsTotal = cpList.Count / 4;
      // Number of required texture pixels to represent 
      // coordinate points for every slot detection area
      // (one RGBA covers 2 out of 4 cornerpoints for a slot)
      int texturePixelCount = numSlotsTotal * 2;
      
      // Create texture that can hold corner pixel location data
      tex = new Texture2D(texturePixelsPerLine, numSlotsTotal);
      Color color = new Color(0f, 0f, 0f, 0f);
      for (int iPixel = 0; iPixel < texturePixelCount; ++iPixel)
      {
        // Two cornerpoints fit in the RGBA structure
        for (int iCp = 0; iCp < 2; ++iCp)
        {
          SlotData.Cornerpoint cp = cpList[iPixel * 2 + iCp];
          // Swap Y coordinate and interpolate pixel values
          imageSlotExtractor.SwapY(ref cp.y, transform.parent.parent.GetSiblingIndex());
          Vector2 interpCp = new Vector2(
            (float)cp.x / planeManager.GetSourceWidth(), 
            (float)cp.y / planeManager.GetSourceHeight());
          // Store interpolated [0...1] values.
          if (iCp % 2 == 0)
          {
            // First coordinate pair that populates RG of RGBA 
            color.r = interpCp.x;
            color.g = interpCp.y;
          }
          else
          {
            // Second coordinate pair that populates BA of RGBA 
            color.b = interpCp.x;
            color.a = interpCp.y;
            colorList.Add(color);
          }
        }
      }
      
      // Setting filter mode to Point is a MUST! With default setting, 
      // there's a LOT of pixel averaging and/or blending. We want 
      // pure blocky content!
      tex.filterMode = FilterMode.Point;
      // Apply color data to the texture
      tex.SetPixels(colorList.ToArray());
      tex.Apply();

      // Pass texture data to the shader
      ///////////////////////////////////
      // Texture
      shaderMaterial.SetTexture("_ColorTex", tex);
      // Texture dimensions
      shaderMaterial.SetInt("_ColorTexWidth", texturePixelsPerLine);
      shaderMaterial.SetInt("_ColorTexHeight", numSlotsTotal);
      // Alternating colors for adjacent sets of four cornerpoints
      shaderMaterial.SetColor("_CornerColor0", cornerPointColorA);
      shaderMaterial.SetColor("_CornerColor1", cornerPointColorB);
      // Source image aspect ratio
      shaderMaterial.SetFloat("_MainTexAspectRatio", 
        (float)planeManager.GetSourceWidth() / planeManager.GetSourceHeight());
      // Radius of colored cornerpoint square in the screen
      shaderMaterial.SetFloat("_CornerpointRadius", edgeCornerPointDisplayRadius);
    }
    // Enable variable needs to be passed outside of conditional block to ensure once enabled
    // borders are erased during playback if the user unselects the option in the inspector
    shaderMaterial.SetFloat("_DisplayCornerpoints", displayEdgeDetectionAreas ? 1.0f : 0.0f);
  }
}

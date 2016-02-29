/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ImageSlotExtractor : MonoBehaviour {
  public float updateSeconds;
  enum BinaryColor { Black = 0, White = 255 };

  SlotData[] slotData;
  Material[] sourceMaterial;
  int numCams;
  bool showDebugInfo = true;

  void Awake() {
    // Get processing cameras, ignore main camera.
    numCams = GetComponent<CamScript>().sourceCameras.Length - 1;
    try
    {
      if (numCams != transform.childCount)
        throw new System.Exception("Source camera miscount detected! " + 
          "Select Source Camera Controller object in the hierarchy to refresh.");
    }
    catch (System.Exception e)
    {
      Debug.LogError(e.Message);
      return;
    }

    slotData = new SlotData[numCams];
    sourceMaterial = new Material[numCams];
  }
  
  void Start() {
    // Populate source plane materials per each processing camera container.
    for (int iCam = 0; iCam < numCams; ++iCam) {
      // NOTE: Custom ImageSlotExtractor script execution order has been set 
      // in Unity. This is due to a delicate timing issue, that would cause
      // either slotData or sourceMaterial assignments below to result in
      // errors depending on whether this loop is in Awake() or in Start().
      slotData[iCam] = transform.GetChild(iCam).GetComponent<SlotScript>().slotData;
      sourceMaterial[iCam] = transform.GetChild(iCam).GetChild(1).
        GetChild(1).GetChild(0).GetComponent<Renderer>().material;
    }

    if (IsOpenGlGraphics())
      // Unity started in OpenGL mode => initiate 
      // an endless image color data extraction loop
      StartCoroutine (ExtractorTimer());
    else
      Debug.LogWarning("The project is using OpenGL shaders but Unity is running in DirectX\n" + 
        "mode. Please restart Unity with -force-opengl command line switch.");
  }

  
  IEnumerator ExtractorTimer() {
    while (true) {
      yield return new WaitForSeconds(updateSeconds);
      yield return new WaitForEndOfFrame();
      ExtractSlots();
    }
  }
  

  public int GetTotalSlotCount() {
    int slotCount = 0;
    // Go through slot data for each processing camera and retrieve
    // the total number of slots the cameras have been setup to track
    for (int iCam = 0; iCam < numCams; ++iCam)
    {
      for (int iRow = 0; iRow < slotData[iCam].numberOfRows; ++iRow)
      {
        SlotData.Row row = slotData[iCam].rows[iRow];
        for (int iSlot = 0; iSlot < row.numberOfSlots; ++iSlot)
        {
          SlotData.Slot slot = row.slots[iSlot];
          if (!slot.IsUndefined())
            ++slotCount;
        }
      }
    }
    return slotCount;
  }

  // Number of processing cameras
  public int GetCameraCount() { return numCams; }

  public int GetRowCount() {
    // Return the highest row count among all cameras for
    // the scene parking lot population mechanism to reserve 
    // enough memory for all rows.
    int numMaxRows = 0;
    for (int iCam = 0; iCam < numCams; ++iCam)
      numMaxRows = Mathf.Max(numMaxRows, slotData[iCam].numberOfRows);
    return numMaxRows;
  }

  public int GetSlotCount(int rowIndex) {
    // Return the highest slot count among all rows matching
    // provided index for the scene parking lot population
    // mechanism to reserve enough memory for all slots.
    int numMaxRowSlots = 0;
    for (int iCam = 0; iCam < numCams; ++iCam)
      // Caller will have called GetRowCount() before this. Having received
      // the maximum number of rows found, it expects to find that number 
      // of rows. However, some cameras may have been assigned a limited 
      // number of rows in the inspector, so the request must be limited 
      // to actual number of rows the camera being currently looped over
      // defines.
      if (slotData[iCam].numberOfRows > rowIndex)
        numMaxRowSlots = Mathf.Max(
          numMaxRowSlots, 
          slotData[iCam].rows[rowIndex].numberOfSlots);
    return numMaxRowSlots;
  }

  public void ExtractSlots()
  {
    // Take snapshots of binary edge detection image and 
    // read pixels and their colors from areas of interest
    ////////////////////////////////////////////////////////

    // Go through processing cameras
    for (int iCam = 0; iCam < numCams; ++iCam)
    {
      if (showDebugInfo)
        Debug.Log("=========== " + transform.GetChild(iCam).name + " ===========");

      // Mark renderTexture active so that Texture2D.ReadPixels()
      // will get pixels from it instead of the entire viewport.
      Transform tShaderPlanes = transform.GetChild(iCam).GetChild(1);
      RenderTexture.active = (RenderTexture)tShaderPlanes.
        GetChild(tShaderPlanes.childCount - 3).GetChild(0).
          GetComponent<Renderer>().material.mainTexture;
      
      for (int iRow = 0; iRow < slotData[iCam].numberOfRows; ++iRow)
      {
        SlotData.Row row = slotData[iCam].rows[iRow];
        for (int iSlot = 0; iSlot < row.numberOfSlots; ++iSlot)
        {
          SlotData.Slot slot = row.slots[iSlot];
          
          if (slot.IsUndefined())
            // Slot corner points unassigned -> stop
            continue;
          // Get a bounding rect to define the target texture dimension
          Rect boundingRect = slot.GetBoundingRect();
          // Create a texture matching bounding rect dimensions
          slot.colorTexture = 
            new Texture2D((int)boundingRect.width, (int)boundingRect.height);
          // Turn user-provided cornerpoint rect Y coordinates (texture top edge 
          // Y == 0) into OpenGL coordinate space (texture bottom edge Y == 0)
          SwapY(ref boundingRect, transform.GetChild(iCam).GetSiblingIndex());
          // Read pixels into texture memory
          slot.colorTexture.ReadPixels(boundingRect, 0, 0);
          // Retrieve pixel RGBA components
          Color32[] colorData = slot.colorTexture.GetPixels32();

          /*
            Pixel In Polygon algorithm:
            - Search the bounding rectangle of the detection area quadrilateral.
              In each Y position, traverse horizontally across the width of the
              rectangle, a line at a time. If at any point the pixel under scrutiny
              has crossed - from left to right - an uneven number of detection 
              area edge lines, it must be within the detection area. In such case,
              if the color in that location is white, consider a hittest a success.
          */

          // Construct line data from detection area corner points
          List<Line> lines = new List<Line>();
          for (int iCp = 0; iCp < slot.areaCornerpoints.Length; ++iCp)
          {
            // Get each adjacent corner point pair
            SlotData.Cornerpoint cp = slot.areaCornerpoints[iCp];
            SlotData.Cornerpoint nextCp = 
              slot.areaCornerpoints[(iCp + 1) % slot.areaCornerpoints.Length];
            // Do OpenGL Y coord swapping
            SwapY(ref cp.y, transform.GetChild(iCam).GetSiblingIndex());
            SwapY(ref nextCp.y, transform.GetChild(iCam).GetSiblingIndex());
            // Use the bounding rect lower (OpenGL) left corner coordinate as the 
            // (0, 0) reference point to create a line from a pair of corner points
            lines.Add(new Line(
              cp.x - (int)boundingRect.x,
              cp.y - (int)boundingRect.y,
              nextCp.x - (int)boundingRect.x,
              nextCp.y - (int)boundingRect.y));
          }
          
          // Start counting the total and relative amount of white pixels
          ///////////////////////////////////////////////////////////////

          int numTotalPx = 0; 
          // int numTotalPx = Mathf.RoundToInt(boundingRect.width * boundingRect.height);
          int numWhiteFound = 0;
          // Go through a black/white binary-processed source image pixel at a time
          for (int iColor = 0; iColor < colorData.Length; ++iColor)
          {
            int crossedLineCount = 0;

            // Get X and Y coordinates being checked
            int textureX = iColor % (int)boundingRect.width;
            int textureY = Mathf.FloorToInt(iColor / boundingRect.width);

            // Go through detection area edge lines, looking for line crossings.
            // Order of scanning will be according to OpenGL coordinate space, 
            // from bottom (y == 0) to top (Y == texture height).
            foreach (Line line in lines)
            {
              if (line.IsPointYInRange(textureY)) {
                // The coordinate is within the Y axis range of the edge line.
                // Get the X position on the line in the Y coordinate. 
                float lineCrossingX = line.GetXFromY(textureY);
                // Compare line X with the X of the location being checked
                if (System.Single.IsNaN(lineCrossingX))
                {
                  // Y coordinate matches horizontal detection area edge line 
                  // => pixel is to be considered to be inside the area and
                  // taken into account.
                  crossedLineCount = 1;
                  break;
                }
                else if (lineCrossingX <= textureX)
                {
                  // Texture X coordinate is to the right of a line crossing
                  ++crossedLineCount;
                }
              }
            }

            if (IsOddLineCount(crossedLineCount))
            {
              // Increase total found amount
              ++numTotalPx;
              if (IsWhiteColor(colorData[iColor]))
              {
                ++numWhiteFound;
              }
            } 
          }

          // Pixel color count done -> calculate results
          int thresholdPixelCount = (int)(slot.pxThresholdLevel * numTotalPx);
          if (showDebugInfo)
          {
            Debug.Log("Parking row # " + (iRow + 1) + ", parking slot # " + (iSlot + 1) + ": " +
              "White pixel / total area pixel count & percentage: " + numWhiteFound + "/" + 
                numTotalPx + ", " + ((float)numWhiteFound / numTotalPx * 100f).ToString("0.00") + "%" +
              "\nFree-to-reserved white pixel threshold count & percentage: " + 
                thresholdPixelCount + ", " + (slot.pxThresholdLevel * 100).ToString("0.00") + "%  " +
                (numWhiteFound > thresholdPixelCount ? "RESERVED" : "FREE"));
          }
          
          // Inform scene maintenance script about slot reservation state
          driveLineController.rows[iRow][iSlot] = numWhiteFound > thresholdPixelCount;
        } // for (int iSlot = 0; iSlot < row.numberOfSlots; ++iSlot)
      } // for (int iRow = 0; iRow < slotData.numberOfRows; ++iRow)
    } // for (int iCam = 0; iCam < numCams - 1; ++iCam)
  }
  


  // Can use any single component (r, g or b) for
  // inspection, as the image is in binary format.
  bool IsWhiteColor(Color32 color) { return color.r == (int)BinaryColor.White; }

  bool IsOddLineCount(int lineCount) { return lineCount % 2 == 1; }

  void SwapY(ref Rect r, int cameraIndex) {
    /*
      "[ReadPixels()] will copy a rectangular pixel area -- (specified by the  
      source parameter) into the position defined by destX and destY. Both 
      coordinates use pixel space - (0,0) is lower left."
      @ http://docs.unity3d.com/ScriptReference/Texture2D.ReadPixels.html

      This only applies to OpenGL. If unity editor / build is using Direct3D
      rendering, (0,0) is coordinate pair to upper left corner.
    */
    if (IsOpenGlGraphics()) // Unity started with -force-opengl or WebGL build
    {
      // Not only does distance of Y need to be "seen" from the opposite
      // texture edge but the rect also has to extend to opposite direction.
      // Therefore, subtract also rect height.
      r.y = sourceMaterial[cameraIndex].mainTexture.height - r.y - r.height - 1;     
    }
  }

  public void SwapY(ref int y, int cameraIndex) {
    if (IsOpenGlGraphics())
      y = sourceMaterial[cameraIndex].mainTexture.height - y - 1;
  }

  bool IsOpenGlGraphics() {
    return SystemInfo.graphicsDeviceType.ToString().Substring(0, 6) == "OpenGL";
  }
}

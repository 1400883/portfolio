/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

[System.Serializable]
public class SlotData {
  [Range(0, 10)]
  // Total number of parking rows
  public int numberOfRows;
  public Row[] rows;

  [System.Serializable]
  public struct Row {
    [Range(0, 15)]
    // Total number of parking slots
    public int numberOfSlots;
    public Slot[] slots;
  }

  [System.Serializable]
  public struct Slot {
    // Corner points of a quadrilateral that encloses 
    // the area of interest for each parking slot
    public Cornerpoint[] areaCornerpoints;
    [Range(0.00f, 1.00f)]
    // Vehicle detection threshold level for each slot's 
    // area of interest (white pixels / all pixels)
    public float pxThresholdLevel;

    // 2D texture memory storage where pixels for each 
    // parking slot under inspection will be saved
    public Texture2D colorTexture;

    public Rect GetBoundingRect()
    {
      int minX = System.Int32.MaxValue, minY = System.Int32.MaxValue; 
      int maxX = 0, maxY = 0;
      // Find min and max X and Y
      foreach (Cornerpoint cp in areaCornerpoints) {
        // X comparison
        if (cp.x < minX) minX = cp.x;
        if (cp.x > maxX) maxX = cp.x;
        // Y comparison
        if (cp.y < minY) minY = cp.y;
        if (cp.y > maxY) maxY = cp.y;
      }
      return new Rect(
        minX, 
        minY,
        maxX - minX, 
        maxY - minY);
    }

    public bool IsUndefined() {
      int refX = areaCornerpoints[0].x;
      int refY = areaCornerpoints[0].y;
      for (int iCp = 1; iCp < areaCornerpoints.Length; ++iCp)
        if (areaCornerpoints[iCp].x != refX || areaCornerpoints[iCp].y != refY)
        // Value difference exists => valid points
          return false;
      return true;
    }
  }

  [System.Serializable]
  public struct Cornerpoint {
    // Corner point coordinates.
    // Sadly, unity has no pre-made container for two ints.
    public int x;
    public int y;
  }
}
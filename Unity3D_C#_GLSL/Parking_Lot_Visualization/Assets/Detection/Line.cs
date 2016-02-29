/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System;
using System.Collections;

public class Line {

  struct Diff {
    public float x;
    public float y;
  }

  Vector2 startPoint;
  Vector2 endPoint;
  Diff diff;
  float slope;
  float yIntercept;

  public Line(Vector2 start, Vector2 end) {
    startPoint = start; 
    endPoint = end;
    slope = (float)(end.y - start.y)/(end.x - start.x);
    CalculateYIntercept();
  }

  public Line(int startX, int startY, int endX, int endY) {
    startPoint = new Vector2(startX, startY); 
    endPoint = new Vector2(endX, endY);
    slope = endX - startX == 0
      // Line endpoint Xs are the same. Slope is positive or negative
      // infinity. Mark this as largest or smallest possible value.
      // ? (endY > startY ? Single.Maxvalue : Single.MinValue)
      ? Single.NaN
      // Slope is a real number. NOTE: slope may be zero, this needs to
      // taken into account later.
      : (float)(endY - startY)/(endX - startX);
      
    CalculateYIntercept();
  }

  void CalculateYIntercept() { 
    // yIntercept = slope > Single.MinValue && slope < Single.MaxValue
    yIntercept = Single.IsNaN(slope)
      // Slope is positive or negative infinity => line will never cross Y axis.
      ? Single.NaN
      // Slope is a real number => line will cross Y axis at some point.
      : startPoint.y - slope * startPoint.x; } 

  public float GetXFromY(float y)
  {
    return Single.IsNaN(slope)
      // Slope is positive or negative infinity => either endpoint X will do.
      // This does not need any extra processing by caller (ImageSlotExtractor).
      // Line formula: x = b
      ? startPoint.x
      : slope == 0 
        // Slope is zero => mark this as NaN.
        // Line formula: y = b
        ? Single.NaN
        // Slope is non-zero real number.
        // Formula: y = ax + b => x = (y - b) / a
        : (y - yIntercept) / slope;
  }

  public bool IsPointYInRange(int y) {
    float largestY = Math.Max(startPoint.y, endPoint.y);
    float smallestY = Math.Min(startPoint.y, endPoint.y);
    return smallestY <= y && largestY >= y; 
  }
}
/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/*
  The script will do processing plane scaling and positioning based on
  source image plane and settings given in the inspector. The script will
  also scale and position the arrow symbols between each two planes, as 
  well as camera title text.
*/

[ExecuteInEditMode]
public class PlaneManager : MonoBehaviour {  
  public float planeScale;
  public float padding;
  public float arrowScale;
  public bool fillFromRightToLeft;
  List<Transform> planeList;
  Transform tSourcePlane;
  textureSize source;
  textureSize arrow;  
  Material sourceMaterial;
  InputImageController iic;
  
  public int GetSourceWidth() { return source.width; }
  public int GetSourceHeight() { return source.height; }

  void Awake() {
  }

  void Start () {
    // NOTE: Material MUST be fetched no sooner than in Start() for
    // multiple processing cameras to have individual images, due to
    // instance materials
    iic = transform.parent.GetComponent<InputImageController>();
    tSourcePlane = transform.GetChild(1).GetChild(0);
    sourceMaterial = tSourcePlane.GetComponent<Renderer>().sharedMaterial;
    
    // A texture may only appear dynamically in the plane during playback.
    // Fall back to another method whenever edit mode execution takes place.
    if (iic.IsUsingNetworkImage())
    {
      // Real network image never present already in Start()
      // => assume default image size.
      // Upon retrieval of the first image from the network 
      // Update() will resize planes to their correct sizes.
      // See also Update() comments about the issue.
      source.width = InputImageController.defaultNetworkImageWidth;
      source.height = InputImageController.defaultNetworkImageHeight;
    }
    else
    {
      if (sourceMaterial.mainTexture == null)
        // No main texture && using local source 
        // image storage => select primary image
        sourceMaterial.mainTexture = iic.GetPrimaryTexture();

      // Main texture exists && using local source image 
      // storage => use actual image dimensions
      source.width = sourceMaterial.mainTexture.width;
      source.height = sourceMaterial.mainTexture.height;
    }

    planeList = new List<Transform>();

    // Add all child objects under Processing Planes object in the
    // list for positioning processing planes, directional arrows 
    // between planes and texts next to planes.
    for (int iTrans = 0; iTrans < transform.childCount; ++iTrans)
    {
      // Skip the source image plane itself
      if (iTrans != 1)
      {
        // Add planes in the List
        Transform child = transform.GetChild(iTrans);
        if (iTrans % 2 == 1)
          child = child.GetChild(0);
        planeList.Add(child);
        // Get texture dimensions for arrows
        if (arrow.width == 0 && child.name == "Arrow")
        {
          Texture t = child.GetComponent<Renderer>().sharedMaterial.mainTexture;
          arrow.width = t.width;
          arrow.height = t.height;
        }
      }
    }
  }

  void Update () {
    
    if (source.width == 0 || arrow.width == 0)
      // During runtime never true, but due to [ExecuteInEditMode] will 
      // resolve to true after script recompilation, causing mayhem
      Start();
    else {
      // Due to delay from fetching a network image for the first time,
      // since playback start, an arbitrary source plane texture size 
      // has been chosen to avoid other scripts that depend on source
      // material dimension information from falling apart big time.
      // Update source size information and resize planes based on the
      // current main texture size to fix dimensional distortion.
      if (sourceMaterial.mainTexture == null) {
        source.width = InputImageController.defaultNetworkImageWidth;
        source.height = InputImageController.defaultNetworkImageHeight;
      }
      else {
        source.width = sourceMaterial.mainTexture.width;
        source.height = sourceMaterial.mainTexture.height;
      }
    }

    // Set source plane scale.
    // NOTE: Z-scaling == world height axis in local space.
    Vector3 tempScale = tSourcePlane.localScale;
    tempScale.x = planeScale;
    tempScale.z = planeScale * source.height / source.width;
    tSourcePlane.localScale = tempScale;
    
    // Distribute plane scaling and positioning across all other 
    // planes, except for arrows that need different scaling.
    ////////////////////////////////////////////////////////////
    // Set distance pointer for the first plane after source image plane
    float distanceFromSource = 
      tSourcePlane.localScale.x / PlaneCameraBinder.planeScaleRatio / 2 + padding;

    for (int iPlane = 0; iPlane < planeList.Count; ++iPlane)
    {
      Transform tCurrent = planeList[iPlane];

      // Do positioning and scaling
      ////////////////////////////////////////

      bool isArrow = tCurrent.name == "Arrow";
      bool isTitle = tCurrent.name == "Camera Title";

      // Get plane position
      Vector3 pos = tSourcePlane.position;

      if (isArrow)
      {
        // Calculate and apply arrow quad scaling
        float scaleRatio = arrowScale * 4;
        tempScale = new Vector3(
          scaleRatio,
          scaleRatio / ((float)arrow.width / arrow.height),
          0.1f);
        tCurrent.localScale = tempScale;

        // Arrow rotation based on fill direction
        Vector3 angle = tCurrent.eulerAngles;
        angle.y = fillFromRightToLeft ? 180f : 0f;
        tCurrent.eulerAngles = angle;
      }
      else if (isTitle)
      {
        // A special treatment for the title text object

        // Scale and position camera title text
        float scaleRatio = tSourcePlane.localScale.x * 2;
        tCurrent.localScale = new Vector3(scaleRatio, scaleRatio, scaleRatio);
        float extent = tCurrent.GetComponent<Renderer>().bounds.extents.x;
        pos.x = tSourcePlane.position.x - (fillFromRightToLeft ? -1 : 1) * 
          (extent + padding + tSourcePlane.GetComponent<Renderer>().bounds.extents.x);
        tCurrent.position = pos;
        continue;
      }
      else
        // Plane scaling matches source plane
        tCurrent.localScale = tSourcePlane.localScale;

      // Get the measure of half of the width of the transform in 
      // Unity units and add it to the total distance from the base
      float halfWidth = tCurrent.localScale.x * 
        (isArrow ? 1 : 1 / PlaneCameraBinder.planeScaleRatio) / 2f;
      distanceFromSource += halfWidth;
      // Adjust X to bring the plane in the next 
      // free "slot" by the side of the source plane
      pos.x += (fillFromRightToLeft ? -1 : 1) * distanceFromSource;
      // Set position
      tCurrent.position = pos;
      // Advance the distance pointer to next "slot" edge
      distanceFromSource += halfWidth + padding;
    }
  }

  struct textureSize {
    public int width;
    public int height;
  }
}

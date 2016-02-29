/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PlaneCameraBinder : MonoBehaviour {

  public static readonly float planeScaleRatio = 0.1f;
  Camera camToBind;

  Texture sourceTexture;
  PlaneManager planeManager;

  void Awake() {
    // Get camera, that is supposed to attach to 
    // the plane, from processing camera container.
    camToBind = transform.parent.parent.parent.
      GetChild(0).GetChild(transform.parent.GetSiblingIndex() / 2).
        GetComponent<Camera>();
    planeManager = transform.parent.parent.GetComponent<PlaneManager>();
  }

  void Start() {}

  void Update() {
    if (planeManager == null)
      // True during edit mode execution
      Awake();

    // Send the text in the child 3D text object to the camera bound to the 
    // plane, to be displayed in the screen when the cam becomes active.
    ////////////////////////////////////////////////////////////////////
    string cameraName = transform.parent.parent.parent.name;
    string planeInfoText = transform.parent.GetChild(1).GetComponent<TextMesh>().text;
    camToBind.GetComponent<ShaderCamGUI>().SetInfoText(
      cameraName + ": " + planeInfoText);

    
    // Setup camera to follow the plane in the scene. 
    // Also match the viewport size to the plane.
    ////////////////////////////////////////////////
    // Set to orthographic. We wish to capture the whole plane, nothing else.
    camToBind.orthographic = true;
    
    // Scale target plane to precisely fit the image
    ////////////////////////////////////////////////
    // Get texture image width / height ratio
    float sizeRatio = 
      (float)planeManager.GetSourceWidth() / planeManager.GetSourceHeight();

    // Evaluates possibly to true due to script execution order issues, 
    // that apparently can't be helped with [ExecuteInEditMode] scripts
    if (!System.Single.IsNaN(sizeRatio))
    {
      // Match camera aspect ratio with texture image
      camToBind.aspect = sizeRatio;
      // Set camera viewport size to match the plane size.
      // x member is the horizontal scaling, x / planeScaleRatio equals the width
      // of the plane in world units (for a default sized plane, 1 / 0.1 == 10).
      // Division by two matches the sizing to camera orthographic size setting,
      // that is, half of the viewport width, and finally division by sizeRatio scales 
      // the width to height.
      camToBind.orthographicSize = 
        transform.localScale.x / planeScaleRatio / 2 / sizeRatio;
    }
    // Set camera position in front of the plane.
    camToBind.transform.position = transform.position + transform.up;
    // Make the camera face the plane.
    camToBind.transform.LookAt(transform);
  }
}

/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PlaneTextBinder : MonoBehaviour {

  Transform descriptionText;

  const float scaleRatio = 1.2f;
  const float margin = 0.1f;

	void Start () {
    // Get text object transforms
    descriptionText = transform.parent.GetChild(1);
	}
	
	void Update() {
    if (descriptionText == null)
      Start();

    // Position processing stage text on top of the plane, horizontally centered
    //////////////////////////////////////////////////////
    Vector3 newPosition = descriptionText.position;
    // Vertical position. Due to plane rotation, its 
    // local Z axis is aligned with the world Y axis.
    // Therefore, use Z scale.
    newPosition.y = transform.position.y + 
      transform.localScale.z / PlaneCameraBinder.planeScaleRatio / 2 +
      margin;
    // Horizontal position
    newPosition.x = transform.position.x;
    descriptionText.position = newPosition;

    // Scale text to match plane size
    Vector3 newScale = descriptionText.localScale;
    newScale.x = transform.parent.GetChild(0).localScale.x * scaleRatio;
    newScale.y = newScale.x;
    descriptionText.localScale = newScale;
	}
}

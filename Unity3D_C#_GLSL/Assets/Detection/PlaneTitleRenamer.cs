/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PlaneTitleRenamer : MonoBehaviour {
  TextMesh tm;

	void Start () {
    // If not set already, transfer camera name from the camera container 
    // object to the text object next to the source image plane
    if (tm == null)
      tm = GetComponent<TextMesh>();
    tm.text = transform.parent.parent.name;
  }
  void Update() {
    Start();
  }
}

/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class CameraPrefabLocator : MonoBehaviour {

  bool isDetectionActive = false;
  const float interval = 2f;
	
	// Update is called once per frame
	void Update () {
    if (!isDetectionActive) {
      // Initiate repeating check just once
      InvokeRepeating("CheckCameraLocations", 0f, interval);
      isDetectionActive = true;
    }
	}

  void CheckCameraLocations() {
    // Get processing cameras
    GameObject[] gArray = GameObject.FindGameObjectsWithTag("SourceCam");
    foreach (GameObject g in gArray)
      if (g.transform.parent != this.transform) {
        // Wrong parent detected
        Debug.LogError(
          "Camera prefab \"" + g.name + "\" hierarchy location mismatch detected." +
          " Make prefab a direct child of " + name + ".");
      }
  }
}

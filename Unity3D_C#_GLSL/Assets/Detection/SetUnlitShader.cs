/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

public class SetUnlitShader : MonoBehaviour {
  void Awake() {
    // Swap default shader to Unlit/Texture for proper lighting
    GetComponent<Renderer>().material.shader = Shader.Find("Unlit/Texture");
  }
}

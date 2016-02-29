/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;
using System.Text.RegularExpressions;

public class ShaderCamGUI : MonoBehaviour {
  public int fontSize;
  public Color fontColor = Color.white;
  public bool showInTop;

  const int textVerticalMargin = 20;

  [Range(0f, 10f)]
  public float fadeDelay;
  [Range(1f, 10f)]
  public float fadeSpeed;

  bool showCamInfo = false;
  string displayText = "";
  GUIStyle style = new GUIStyle();

  void OnGUI() {
    if (showCamInfo)
    {
      // Display GUI text element only when the processing 
      // cam associated with the script is activated

      // Create a style to set font properties
      style.fontSize = fontSize;
      style.fontStyle = FontStyle.Bold;
      style.normal.textColor = fontColor;

      // Calculate font dimensions
      Vector2 textSize = style.CalcSize(new GUIContent(displayText));
      while (textSize.x > Screen.width) {
        // Split line near the midpoint if text too long
        SplitLine();
        // Re-calculate
        textSize = style.CalcSize(new GUIContent(displayText));
      }
      
      // Make text snap in the margin's length off the upper 
      // right corner of the screen, irrespective of font size.
      GUI.Label(new Rect(
        Screen.width / 2f - textSize.x / 2,
        (showInTop ? 0 : Screen.height - textSize.y) + 
          (showInTop ? 1 : -1) * textVerticalMargin, 
        textSize.x, 
        textSize.y), displayText, style);
    }
  }

  void SplitLine() {
    // Find the middlemost space in the string and split there
    //////////////////////////////////////////////////////////
    int strLen = displayText.Length;
    bool isEvenlyDivisibleCount = strLen % 2 == 0;
    int iStartChar = Mathf.CeilToInt((float)strLen / 2) - 1;
    int iSpaceChar = 0;
    for (int iChar = 0; iChar < iStartChar + 1; ++iChar)
    {
      // string   strLen  strlen % 2  iStartChar (bw) iStartChar (fw)
      // N        1       1           0               0
      // NN       2       0           0               1
      // NNN      3       1           1               1
      // NNNN     4       0           1               2
      if (displayText[iStartChar - iChar] == ' ') {
        // A space found towards the beginning of 
        // the string counting from the midway point
        iSpaceChar = iStartChar - iChar;
        break;
      }
      else if (displayText[iStartChar + iChar + (isEvenlyDivisibleCount ? 1 : 0)] == ' ') {
        // A space found towards the end of the
        // string counting from the midway point
        iSpaceChar = iStartChar + iChar + (isEvenlyDivisibleCount ? 1 : 0);
        break;
      }
    }

    // Construct substrings split in the middlemost space position
    string[] subStr = new string[2];
    subStr[0] = displayText.Substring(0, iSpaceChar);
    subStr[1] = displayText.Substring(iSpaceChar + 1);

    // Combine with a newline
    displayText = subStr[0] + "\n" + subStr[1];
  }

  public void SetInfoText(string text) {
    // Remove leading spaces from each individual line
    displayText = Regex.Replace(text, @"^\s*(.*)$", "$1", RegexOptions.Multiline);
    // Replace line breaks with spaces
    displayText = displayText.Replace("\n", " ");
    // Replace multi-spaces with single spaces
    displayText = Regex.Replace(displayText, @" {2,}", " ");

  }

  Coroutine coroutine;
  public void SetCamInfoDisplayState(bool newState) {
    showCamInfo = newState;
    if (newState) {
      // Camera view was entered -> initiate fadeout
      fontColor.a = 1f;
      coroutine = StartCoroutine(ShowAndFade());
    }
    else if (coroutine != null)
      // If set, cancel. This guarantees fade effect 
      // gets reset on active processing cam view change.
      StopCoroutine(coroutine); 
  }

  IEnumerator ShowAndFade() {
    // Pre-delay
    yield return new WaitForSeconds(fadeDelay);
    while (fontColor.a > 0f && showCamInfo)
      yield return StartCoroutine(FadeOut());

  }

  IEnumerator FadeOut() {
    // Fade out at user-defined speed
    yield return new WaitForSeconds(0.10f / fadeSpeed);
    if (fontColor.a > 0f) {
      fontColor.a -= 0.02f;
      if (fontColor.a < 0f)
        fontColor.a = 0f;
    }
  }
}

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PerformanceGUI : MonoBehaviour {

    public int fontSize;
    public int fontMargin;
    public Color fontColor;

    int fps;
    int frames;

	// Use this for initialization
	void Start () {
        StartCoroutine("CountFPS");
	}
	
	// Update is called once per frame
	void Update () {
        frames++;
	}

    void OnGUI() {
        string displayText = "FPS: " + fps;
        // Create a style to set font properties
        GUIStyle style = new GUIStyle();
        style.fontSize = fontSize;
        style.fontStyle = FontStyle.Bold;
        // Calculate font dimensions
        Vector2 textSize = style.CalcSize(new GUIContent(displayText));
        
        GUI.color = fontColor;

        // Make text snap in the margin's length off the upper 
        // right corner of the screen, irrespective of font size.
        GUI.Label(new Rect(
            Screen.width - textSize.x - fontMargin,
            // The default font apparently has character height greater than
            // height of numbers. This  scales up with the font size, altering
            // vertical upper pivot point with scaling. Compensate that
            // by a constant. 7 came by trial and error.
            fontMargin - (textSize.y / 7), 
            textSize.x, 
            textSize.y), displayText, style);
    }
    
    IEnumerator CountFPS()
    {
        while(true) {
            fps = frames;
            frames = 0;
            yield return new WaitForSeconds(1.0f);
        }
    }
}

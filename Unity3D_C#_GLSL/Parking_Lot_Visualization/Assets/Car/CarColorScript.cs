using UnityEngine;
using System.Collections;

public class CarColorScript : MonoBehaviour {
	
	void Awake() {
		ChangeMaterial ();
	}

	void ChangeMaterial()
	{
        // Eight "basic" colors
        int y = Random.Range (0, 15);
        if (y == 0) gameObject.GetComponent<Renderer>().material.color = Color.red;
        if (y == 1) gameObject.GetComponent<Renderer>().material.color = Color.blue;
        if (y == 2) gameObject.GetComponent<Renderer>().material.color = Color.black;
        if (y == 3) gameObject.GetComponent<Renderer>().material.color = Color.white;
        if (y == 4) gameObject.GetComponent<Renderer>().material.color = Color.green;  
        if (y == 5) gameObject.GetComponent<Renderer>().material.color = Color.yellow;
        if (y == 6) gameObject.GetComponent<Renderer>().material.color = Color.gray;
        if (y == 7) gameObject.GetComponent<Renderer>().material.color = Color.magenta;
        if (y == 8) gameObject.GetComponent<Renderer>().material.color = Color.cyan;
        if (y > 8)
        {
            // Create a new color randomly
            float r, g, b;
            r = Random.Range(0.0f, 1.0f);
            g = Random.Range(0.0f, 1.0f);
            b = Random.Range(0.0f, 1.0f);
            
            Color tmpColor = new Color(r, g, b);
            gameObject.GetComponent<Renderer>().material.color = tmpColor;
        }
    }
}
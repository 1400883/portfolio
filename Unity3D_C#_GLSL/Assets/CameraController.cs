using UnityEngine;
using System.Collections;

public class CameraController : MonoBehaviour {

    public float speed = 0.05f;
    public float mouseSensitivity = 2.0f;
    public bool limitCameraMovement = true;
    public float dist_x;
    public float dist_y;

    // for WebGL debugging
    public bool cursorHiding = true;

    // GameObjects limiting camera movement
    public Transform x_max;
    public Transform x_min;
    public Transform z_max;
    public Transform z_min;
    public Transform y_max;
    public Transform y_min;


	// Update is called once per frame
	void Update () {

        //////////////////////////
        // MOVEMENT - WASD-KEYS //
        //////////////////////////

        // Uses local positions to factor in transform rotation

        // Set two local vectors
        Vector3 forward = transform.TransformDirection(Vector3.forward);
        Vector3 right = transform.TransformDirection(Vector3.right);

        // Move transform..
        // Forward
        if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.UpArrow))
        {
            transform.localPosition += forward * speed;
        }

        // Back
        if (Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow))
        {
            transform.localPosition += -forward * speed;
        }

        // Right
        if (Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.RightArrow))
        {
            transform.localPosition += right  * speed;
        }

        // Left
        if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.LeftArrow))
        {
            transform.localPosition += -right * speed;
        }


        ///////////////////////////////
        // ROTATION - MOUSE CONTROLS //
        ///////////////////////////////

        // Uses mouseSensitivity as a multiplier for rotation speed

        // Works only with right mouse button down
        if (Input.GetKey(KeyCode.Mouse1))
        {
            Vector3 tmpRot = transform.eulerAngles;

            // Change transform rotation according to mouse movement between frames
            // X-axis
            tmpRot.y += Input.GetAxis("Mouse X") * mouseSensitivity;

            // Y-axis
            tmpRot.x -= Input.GetAxis("Mouse Y") * mouseSensitivity;

            // Set transform rotation to temporary variable
            transform.eulerAngles = tmpRot;
        }

        ////////////////////////////
        // CAMERA MOVEMENT LIMITS //
        ////////////////////////////

        // Only if limiting camera movement
        if (limitCameraMovement)
        {
            // Clamp current transform position to fit limits
            float x = Mathf.Clamp(transform.position.x, x_min.position.x, x_max.position.x);
            float y = Mathf.Clamp(transform.position.y, y_min.position.y, y_max.position.y);
            float z = Mathf.Clamp(transform.position.z, z_min.position.z, z_max.position.z);

            // Set transform position
            transform.position = new Vector3(x, y, z);
        }


        // NOTE: WebGL-build asks if browser can hide mouse cursor, but works afterwards (tested in firefox)
        // Chrome asks for cursor hiding every time

        // Hide and confine cursor on mouse down
        if (cursorHiding)
        {
            if (Input.GetKeyDown(KeyCode.Mouse1))
            {
                Cursor.visible = false;
                Cursor.lockState = CursorLockMode.Locked;
            }
            // Release and show cursor on mouse up
            if (Input.GetKeyUp(KeyCode.Mouse1))
            {
                Cursor.visible = true;
                Cursor.lockState = CursorLockMode.None;
            }
        }
    }
}

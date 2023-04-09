using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerMovement : MonoBehaviour
{
    private Rigidbody rb;
    [Space(10)]
    [Header("Fisicas")]

    public float moveForce;
    public float jumpForce;

    [Space(10)]
    [Header("Line Render")]
    public LineRenderer laserLineRenderer;
    public float laserWidth = 0.1f;
    public float laserMaxLength = 5f;
    // Start is called before the first frame update
    void Start()
    {
        rb= GetComponent<Rigidbody>();

        Vector3[] initLaserPositions = new Vector3[2] { Vector3.zero, Vector3.zero };
        laserLineRenderer.SetPositions(initLaserPositions);
        laserLineRenderer.startWidth = laserWidth;
    }

    // Update is called once per frame
    void Update()
    {
        movement();
    }


    public void movement()
    {
        float h = Input.GetAxisRaw("Horizontal");
        float v = Input.GetAxisRaw("Vertical");


        rb.AddForce(Vector3.forward * (v*moveForce));
        rb.AddForce(Vector3.right * (h*moveForce));

        if (Input.GetKeyDown(KeyCode.Space))
        {
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
        }

        //Raycast

        if (Input.GetKey(KeyCode.LeftControl))
        {
            ShootLaserFromTargetPosition(transform.position, Vector3.forward, laserMaxLength);
            laserLineRenderer.enabled = true;
        }
        else
        {
            laserLineRenderer.enabled = false;
        }
    }


    void ShootLaserFromTargetPosition(Vector3 targetPosition, Vector3 direction, float length)
    {
        Ray ray = new Ray(targetPosition, direction);
        RaycastHit raycastHit;
        Vector3 endPosition = targetPosition + (length * direction);

        if (Physics.Raycast(ray, out raycastHit, length))
        {
            endPosition = raycastHit.point;
            laserLineRenderer.startColor = Color.green;
            laserLineRenderer.endColor = Color.green;
            print(raycastHit.collider.gameObject.name);
        }
        else
        {
            laserLineRenderer.startColor = Color.red;
            laserLineRenderer.endColor = Color.red;
        }

        laserLineRenderer.SetPosition(0, targetPosition);
        laserLineRenderer.SetPosition(1, endPosition);
    }
}

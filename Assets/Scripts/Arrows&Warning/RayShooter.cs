using UnityEngine;

public class RayShooter : MonoBehaviour
{
    private void Update()
    {
        RaycastHit hitInfo;
        if (Physics.Raycast(transform.position, transform.forward, out hitInfo))
        {
            var drawSquareTarget = hitInfo.transform.GetComponent<DrawSquareWhereHitSensor>();

            if (drawSquareTarget)
            {
                drawSquareTarget.TakeHit(hitInfo.point);
            }
        }
    }
}

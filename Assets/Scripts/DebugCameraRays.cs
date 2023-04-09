using UnityEngine;

[ExecuteInEditMode]
public class DebugCameraRays : MonoBehaviour
{
    private Camera m_Camera;

    private void Start()
    {
        m_Camera = GetComponent<Camera>();
    }

    private void OnDrawGizmos() 
    {
        Gizmos.color = Color.green;

        Vector2 dimensions = new Vector2(0, 1);
        dimensions.x = m_Camera.aspect * dimensions.y;

        Vector2 uv;
        for (int y = 0; y < 20; y++)
        {
            for (int x = 0; x < 20; x++)
            {
                uv = dimensions / new Vector2(20, 20) * new Vector2(x, y) * 2 - dimensions;
                Ray ray = GetCameraRay(uv);
                Gizmos.DrawRay(ray.origin, ray.direction * 1000);
            }
        }
    }

    private Ray GetCameraRay(Vector2 uv)
    {
        Matrix4x4 cameraToWorld = m_Camera.cameraToWorldMatrix;
        Matrix4x4 cameraInvProjection = m_Camera.projectionMatrix.inverse;

        Vector3 origin = cameraToWorld.MultiplyPoint(new Vector3(0, 0, 0));
        Vector3 direction = cameraInvProjection.MultiplyPoint(new Vector3(uv.x, uv.y, 0));
        direction = cameraToWorld.MultiplyVector(direction);
        direction = direction.normalized;

        return new Ray(origin, direction);
    }
}

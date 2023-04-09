using UnityEngine;

[ExecuteInEditMode]
public class SDFSphere : MonoBehaviour
{
    [SerializeField] private float m_Radius = 0.5f;
    
    public Vector3 Position => transform.position;
    public float Radius => m_Radius;
}

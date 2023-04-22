using UnityEngine;

[ExecuteInEditMode]
public class SDFBox : MonoBehaviour
{
    [SerializeField] private Vector3 m_Bounds = new Vector3(0.5f, 0.5f, 0.5f);
    
    public Vector3 Position => transform.position;
    public Vector3 Bounds => m_Bounds;
}
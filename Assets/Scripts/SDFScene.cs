using UnityEngine;

[ExecuteInEditMode]
public class SDFScene : MonoBehaviour
{
    [SerializeField] private Material m_Material;
    [SerializeField] private SDFSphere[] m_SDFSpheres = new SDFSphere[5];
    
    private Vector4[] m_SpheresPosition = new Vector4[5];
    private float[] m_SpheresRadius = new float[5];
    private int m_SphereCount;

    private void Update()
    {
        UpdateShapes();
        SendToGPU();
    }

    private void UpdateShapes()
    {
        m_SphereCount = 0;
        for (uint i = 0; i < m_SDFSpheres.Length; i++)
        {
            if (!m_SDFSpheres[i]) return;
            m_SpheresPosition[m_SphereCount] = m_SDFSpheres[i].Position;
            m_SpheresRadius[m_SphereCount] = m_SDFSpheres[i].Radius;
            m_SphereCount++;
        }
    }

    private void SendToGPU()
    {
        if (m_Material)
        {
            m_Material.SetVectorArray("_SpheresPos", m_SpheresPosition);
            m_Material.SetFloatArray("_SpheresRadius", m_SpheresRadius);
            m_Material.SetInteger("_ActiveSpheres", m_SphereCount);
        }
    }
}

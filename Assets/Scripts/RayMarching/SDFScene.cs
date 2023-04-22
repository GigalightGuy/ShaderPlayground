using UnityEngine;

[ExecuteInEditMode]
public class SDFScene : MonoBehaviour
{
    [SerializeField] private Material m_Material;
    [SerializeField] private SDFSphere[] m_SDFSpheres = new SDFSphere[5];
    [SerializeField] private SDFBox[] m_SDFBoxes = new SDFBox[5];
    
    private Vector4[] m_SpheresPosition = new Vector4[5];
    private float[] m_SpheresRadius = new float[5];
    private int m_SphereCount;

    private Vector4[] m_BoxesPosition = new Vector4[5];
    private Vector4[] m_BoxesBounds = new Vector4[5];
    private int m_BoxCount;

    private void Update()
    {
        UpdateShapes();
        SendToGPU();
    }

    private void UpdateShapes()
    {
        // Spheres
        m_SphereCount = 0;
        for (uint i = 0; i < m_SDFSpheres.Length; i++)
        {
            if (!m_SDFSpheres[i]) break;
            m_SpheresPosition[m_SphereCount] = m_SDFSpheres[i].Position;
            m_SpheresRadius[m_SphereCount] = m_SDFSpheres[i].Radius;
            m_SphereCount++;
        }

        // Boxes
        m_BoxCount = 0;
        for (uint i = 0; i < m_SDFBoxes.Length; i++)
        {
            if (!m_SDFBoxes[i]) break;
            m_BoxesPosition[m_BoxCount] = m_SDFBoxes[i].Position;
            m_BoxesBounds[m_BoxCount] = m_SDFBoxes[i].Bounds;
            m_BoxCount++;
        }
    }

    private void SendToGPU()
    {
        if (m_Material)
        {
            // Spheres
            m_Material.SetVectorArray("_SpheresPos", m_SpheresPosition);
            m_Material.SetFloatArray("_SpheresRadius", m_SpheresRadius);
            m_Material.SetInteger("_ActiveSpheres", m_SphereCount);

            // Boxes
            m_Material.SetVectorArray("_BoxesPos", m_BoxesPosition);
            m_Material.SetVectorArray("_BoxesBounds", m_BoxesBounds);
            m_Material.SetInteger("_ActiveBoxes", m_BoxCount);
        }
    }
}

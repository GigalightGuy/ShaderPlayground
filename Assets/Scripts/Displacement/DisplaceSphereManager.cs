using UnityEngine;

[ExecuteInEditMode]
public class DisplaceSphereManager : MonoBehaviour
{
    [SerializeField] private Material m_DisplaceMat;

    [SerializeField] private float m_DisplacementRadius = 1.0f;

    private int m_DisplacementPosPropertyId;
    private int m_DisplacementRadiusPropertyId;

    private void Start() 
    {
        m_DisplacementPosPropertyId = Shader.PropertyToID("_DisplacementPos");
        m_DisplacementRadiusPropertyId = Shader.PropertyToID("_DisplacementRadius");
    }

    private void Update() 
    {
        if (!m_DisplaceMat) return;

        m_DisplaceMat.SetVector(m_DisplacementPosPropertyId, transform.position);
        m_DisplaceMat.SetFloat(m_DisplacementRadiusPropertyId, m_DisplacementRadius);
    }
}

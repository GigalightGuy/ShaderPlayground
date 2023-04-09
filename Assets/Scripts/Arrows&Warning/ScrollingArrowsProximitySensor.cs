using UnityEngine;

public class ScrollingArrowsProximitySensor : MonoBehaviour
{
    [SerializeField] private GameObject m_ObjectToSense;
    [SerializeField] private float m_MaxScrollSpeed = 1.0f;
    [SerializeField] private float m_MaxDetectionRange = 15.0f;

    private MeshRenderer m_MeshRenderer;

    private float m_UVOffset;

    private void Awake()
    {
        m_MeshRenderer = GetComponent<MeshRenderer>();
    }

    private void Update()
    {
        if (!m_ObjectToSense) return;

        float dist = Vector3.Distance(transform.position, m_ObjectToSense.transform.position);

        float speedMultiplier = Mathf.Max(m_MaxDetectionRange - dist, 0) / m_MaxDetectionRange;

        m_UVOffset += m_MaxScrollSpeed * speedMultiplier * Time.deltaTime;

        m_MeshRenderer.material.SetFloat("_UVOffset", m_UVOffset);
    }
}

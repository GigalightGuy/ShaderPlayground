using System;
using System.Collections;
using Unity.VisualScripting.FullSerializer;
using UnityEngine;

public class AnimatedCubeGrid : MonoBehaviour
{
    private const int k_MaxResolution = 1000;

    private static readonly int s_PositionsId = Shader.PropertyToID("_Positions");
    private static readonly int s_ResolutionId = Shader.PropertyToID("_Resolution");
    private static readonly int s_SpacingId = Shader.PropertyToID("_Spacing");
    private static readonly int s_TimeId = Shader.PropertyToID("_Time");

    [SerializeField] private Material m_Material;
    [SerializeField] private Mesh m_Mesh;

    [SerializeField, Range(10, k_MaxResolution)]
    private int m_Resolution = 100;

    [SerializeField] private ComputeShader m_ComputeShader;

    private ComputeBuffer m_PositionsBuffer;

    private void OnEnable()
    {
        m_PositionsBuffer = new ComputeBuffer(k_MaxResolution * k_MaxResolution, 3 * sizeof(float));
    }

    private void OnDisable()
    {
        m_PositionsBuffer.Release();
        m_PositionsBuffer = null;
    }

    private void Update()
    {
        ComputeInGPU();
    }

    private void ComputeInGPU()
    {
        if (!m_Material || !m_Mesh || !m_ComputeShader) return;

        float spacing = 2.0f / m_Resolution;
        m_ComputeShader.SetInt(s_ResolutionId, m_Resolution);
        m_ComputeShader.SetFloat(s_SpacingId, spacing);
        m_ComputeShader.SetFloat(s_TimeId, Time.time);

        m_ComputeShader.SetBuffer(0, s_PositionsId, m_PositionsBuffer);

        int threadGroups = Mathf.CeilToInt(m_Resolution / 8.0f);
        m_ComputeShader.Dispatch(0, threadGroups, threadGroups, 1);


        m_Material.SetBuffer(s_PositionsId, m_PositionsBuffer);
        m_Material.SetFloat(s_SpacingId, spacing);

        var bounds = new Bounds(Vector3.zero, Vector3.one * (2.0f + 2.0f / m_Resolution));
        Graphics.DrawMeshInstancedProcedural(m_Mesh, 0, m_Material, bounds, m_Resolution * m_Resolution);
    }
}

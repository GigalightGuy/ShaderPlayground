using System;
using System.Collections;
using UnityEngine;

public class CubeGrid : MonoBehaviour
{
    [SerializeField] private GameObject m_CubePrefab;
    [SerializeField] private ComputeShader m_CubeShader;

    [SerializeField] private int m_CubesPerAxis = 80;
    [SerializeField] private int m_Repetitions = 1000;

    [SerializeField] private bool m_UseGPU = false;

    private GameObject[] m_Cubes;

    private ComputeBuffer m_CubeHeightsBuffer;

    private float[] m_CubeHeights;

    private void Awake()
    {
        m_CubeHeightsBuffer = new ComputeBuffer(m_CubesPerAxis * m_CubesPerAxis, sizeof(float));
    }

    private void Start()
    {
        CreateGrid();
    }

    private void OnDestroy()
    {
        m_CubeHeightsBuffer.Release();
    }

    private void CreateGrid()
    {
        m_Cubes = new GameObject[m_CubesPerAxis * m_CubesPerAxis];
        m_CubeHeights = new float[m_CubesPerAxis * m_CubesPerAxis];

        for (int z = 0, i = 0; z < m_CubesPerAxis; z++)
        {
            for (int x = 0;  x < m_CubesPerAxis; x++, i++)
            {
                m_Cubes[i] = Instantiate(m_CubePrefab, transform);
                m_Cubes[i].transform.position = new Vector3(x, 0, z);
            }
        }

        StartCoroutine(UpdateCubeGrid());
    }

    private IEnumerator UpdateCubeGrid()
    {
        while (true)
        {
            if (m_UseGPU)
            {
                UpdatePositionsGPU();
            }
            else
            {
                UpdatePositionsCPU();
            }

            for (int i = 0; i < m_Cubes.Length; i++)
            {
                m_Cubes[i].transform.localPosition = 
                    new Vector3(m_Cubes[i].transform.localPosition.x, m_CubeHeights[i], m_Cubes[i].transform.localPosition.z);
            }

            yield return new WaitForSeconds(1);
        }
    }

    private void UpdatePositionsCPU()
    {
        for (int i = 0; i < m_CubeHeights.Length; i++) 
        { 
            for (int j = 0; j < m_Repetitions;  j++)
            {
                m_CubeHeights[i] = UnityEngine.Random.Range(-1.0f, 1.0f);
            }
        }
    }

    private void UpdatePositionsGPU()
    {
        m_CubeShader.SetBuffer(0, "_Positions", m_CubeHeightsBuffer);

        m_CubeShader.SetInt("_CubesPerAxis", m_CubesPerAxis);
        m_CubeShader.SetInt("_Repetitions", m_Repetitions);
        m_CubeShader.SetFloat("_Time", Time.deltaTime);

        int workGroups = Mathf.CeilToInt(m_CubesPerAxis / 8.0f);
        m_CubeShader.Dispatch(0, workGroups, workGroups, 1);

        m_CubeHeightsBuffer.GetData(m_CubeHeights);
    }
}

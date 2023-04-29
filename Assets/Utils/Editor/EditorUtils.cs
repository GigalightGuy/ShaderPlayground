using System.Diagnostics;
using System.IO;
using UnityEditor;

namespace PS.Utils.Editor
{
    public static class Utils
    {
        [MenuItem("Assets/Utils/Open with VS Code")]
        public static void OpenWithVSCode()
        {
            string path = AssetDatabase.GetAssetPath(Selection.activeInstanceID);

            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = "code",
                Arguments = path
            };

            Process.Start(psi);
        }

        const string k_ShaderIncludeTemplateCode =
            "#if !defined(NEW_SHADER_INCLUDED)\n" +
            "#define NEW_SHADER_INCLUDED\n" +
            "\n" +
            "#endif";

        [MenuItem("Assets/Create/Shader/HLSL Include File")]
        public static void CreateHLSLIncludeFile()
        {
            string path = AssetDatabase.GetAssetPath(Selection.activeInstanceID);

            File.WriteAllText(Path.Combine(path, "NewShaderInclude.hlsl"), k_ShaderIncludeTemplateCode);

            AssetDatabase.Refresh();
        }

    }

}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(CommandData))]
public class CommandCustomEditor : Editor
{   

    public override void OnInspectorGUI()
    {
        serializedObject.Update();        
        
        CommandData data = target as CommandData;

        data.type = (CMDType)EditorGUILayout.EnumPopup("CMD Type",data.type);

        if (data.type != CMDType.None)
        {
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            data.cmdName = EditorGUILayout.TextField("CMD Name", data.cmdName);

            EditorGUILayout.Space(8);
            data.objectCommand = EditorGUILayout.TextField("Object", data.objectCommand);
            EditorGUILayout.Space(1);
            data.typeCommand = EditorGUILayout.TextField("Type", data.typeCommand);
            EditorGUILayout.Space(1);
            switch (data.type)
            {
                case CMDType.Player:
                    data.objectCommand = "player";
                    break;
                case CMDType.Prefab:
                    data.objectCommand = "spawn";
                    data.prefab = (GameObject)EditorGUILayout.ObjectField("Prefab", data.prefab, typeof(GameObject), true);
                    break;
                case CMDType.Scene:
                    data.objectCommand = "move";
                    break;
                case CMDType.None:
                    data.objectCommand = "";
                    break;
            }            
            EditorGUILayout.Space(1);
            if (data.type !=CMDType.Prefab)
            {
                data.sendCommand = EditorGUILayout.TextField("Send", data.sendCommand);
                EditorGUILayout.Space(1);
            }
            EditorGUILayout.LabelField("Command Description");
            data.description = EditorGUILayout.TextArea(data.description, GUILayout.Height(100));

            if (GUI.changed)
            {
                EditorUtility.SetDirty(data);
            }
            serializedObject.ApplyModifiedProperties();
        }

    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(DialogueData))]
public class DialogueCustomEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        DialogueData data = target as DialogueData;

        for (int i = 0; i < data.Length; i++)
        {
            data[i].index = i;
        }
    }

}

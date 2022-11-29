using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class DialogueText
{
    public int index;
    [TextArea]
    public string text;
}

[CreateAssetMenu(fileName = "DialogueData", menuName = "DataContainer/DialogueData")]
public class DialogueData : DataContainer<DialogueText>
{
    
}

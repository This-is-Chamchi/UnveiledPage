using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public enum CMDType
{ 
    None,
    Manager,
    Player,
    Prefab,
    Scene,
}

[CreateAssetMenu(fileName = "CommandData", menuName = "DataContainer/CommandData")]
public class CommandData : ScriptableObject
{
    public CMDType type;
    public string cmdName;
    public string objectCommand;
    public string typeCommand;
    public GameObject prefab;
    public string sendCommand;    
    public string description;
}

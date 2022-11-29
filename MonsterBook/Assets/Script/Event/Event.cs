using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Event : MonoBehaviour
{
    public abstract void StartEvent();
    public abstract void StartEvent(float time);
}

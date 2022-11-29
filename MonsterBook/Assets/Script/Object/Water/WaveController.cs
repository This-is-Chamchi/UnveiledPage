using MoveingSurface;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveController : MonoBehaviour
{
    [SerializeField] private Water_Wave[] wavePack;


    private void SetEvent(bool value)
    {
        for (int i = 0; i < wavePack.Length; i++)
        {
            if (value) wavePack[i].MoveWave();
            else wavePack[i].StopWave();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        SetEvent(true);
    }

    private void OnTriggerExit(Collider other)
    {
        SetEvent(false);
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldDrop : MonoBehaviour
{
    private Transform spawnPos;


    private void Awake()
    {
        spawnPos = transform.GetChild(0);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player") || other.gameObject.layer == LayerMask.NameToLayer("PlayerDash"))
        {
            other.transform.position = spawnPos.position;
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale);
    }
}

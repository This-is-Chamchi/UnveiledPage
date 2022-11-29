using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SavePointTrigger : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        GameManager.SetSavePoint(transform.position);
    }
}

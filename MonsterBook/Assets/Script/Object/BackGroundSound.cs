using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BackGroundSound : MonoBehaviour
{
    [SerializeField] private string sound;
    [SerializeField] private float time;


    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("CameraView"))
        {
            SoundManager.PlayVFXSound(sound, transform.position);
        }
    }

    private IEnumerator Routine()
    {
        yield return YieldInstructionCache.waitForSeconds(time);
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformEffector : MonoBehaviour
{
    [SerializeField] private float angle;
    [SerializeField] private bool isPlay;
    private Transform target;


    private void Start()
    {
        target = GameManager.GetPlayerTransform();
        if (isPlay) StartCoroutine(UpdateRoutine());
    }

    private IEnumerator UpdateRoutine()
    {
        while (isPlay)
        {
            var tar = transform.position.y > target.position.y + .1f /*&& Mathf.Abs(Vector3.SignedAngle(Vector3.down, target.position - transform.position, transform.forward)) < angle*/ ? LayerMask.NameToLayer("NullPlatform") : LayerMask.NameToLayer("Platform");

            //Debug.Log(Vector3.SignedAngle(Vector3.down, target.position - transform.position, transform.forward));
            gameObject.layer = tar;
            yield return YieldInstructionCache.waitForEndOfFrame;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("CameraView"))
        {
            if (!isPlay)
            {
                isPlay = true;
                StartCoroutine(UpdateRoutine());
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("CameraView"))
        {
            isPlay = false;
        }
    }

    public static float GetAngle(Vector3 vStart, Vector3 vEnd)
    {
        Vector3 v = vEnd - vStart;

        return Mathf.Atan2(v.y, v.x) * Mathf.Rad2Deg;
    }
}

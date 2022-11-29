using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEngine;

public class ZoneDivideController : MonoBehaviour
{
    [SerializeField] private Transform monsterPack;
    [SerializeField] private Transform openPack;
    [SerializeField] private Transform closePack;

    [SerializeField] private SequenceEvent clearEvent;
    [SerializeField] private float clearDelay;
    [SerializeField] private Event timmer;
    [SerializeField] private float timmerDelay;
    [SerializeField] private float inputTime;

    private bool isCheck;


    #region Trigger Function
    public void StartDivide()
    {
        if (isCheck) return;
        StartCoroutine(Routine());
    }

    public void OpenZone()
    {
        closePack.gameObject.SetActive(false);
        openPack.gameObject.SetActive(true);
    }

    public void CloseZone()
    {
        closePack.gameObject.SetActive(true);
    }

    #endregion

    private IEnumerator Routine()
    {
        CloseZone();
        isCheck = true;
        while (isCheck)
        {
            if (monsterPack.childCount <= 0) break;

            yield return YieldInstructionCache.waitForFixedUpdate;
        }
        GameManager.SetInGameInput(false);
        OpenZone();
        if (timmer != null) timmer.StartEvent(timmerDelay);
        if (clearEvent != null) clearEvent.StartEvent(clearDelay);
        yield return YieldInstructionCache.waitForSeconds(inputTime);
        GameManager.SetInGameInput(true);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player") || other.gameObject.layer == LayerMask.NameToLayer("PlayerDash"))
        {
            StartDivide();
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale);
    }

}

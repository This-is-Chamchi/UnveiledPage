using ladius3565;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class BossDirector : MonoBehaviour
{
    [Header("[Stage 1]")]
    [SerializeField] private FlipBook book;

    [Header("[Paper Object]")]
    [SerializeField] private PaperObject[] leftPage;
    [SerializeField] private SequenceEvent rightPage;

    [Header("[Valule]")]
    [SerializeField] private float startWaitTime;
    [SerializeField] private float endWaitTime;

    [Header("[Stage 2]")]
    [SerializeField] private SequenceEvent SequenceEvent;
    [SerializeField] private Transform cameraPos;


    public void StartEvent()
    {        
        StartCoroutine(Routine());
    }

    private IEnumerator Routine()
    {
        GameManager.SetInGameInput(false);
        CameraController.StartDirectCamera(CameraController.Instance.transform.position);
        yield return YieldInstructionCache.waitForSeconds(startWaitTime);

        for (int i = 0; i < leftPage.Length; i++)
        {
            leftPage[i].StartEvent();
        }
        book.StartEvent();

        

        while (book.GetIsPlay())
        {
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
        rightPage.StartEvent(0);        
        yield return YieldInstructionCache.waitForSeconds(1);
        GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>().ChangePatrol();

    }
    
    public void MoveNextStage()
    {
        StartCoroutine(NextStageRoutine());
    }

    private IEnumerator NextStageRoutine()
    {
        SoundManager.StopBGM();
        GameManager.FadeEffect(true, 2);
        yield return YieldInstructionCache.waitForSeconds(endWaitTime);
        SceneManager.LoadScene(2);
    }

    public void PageEvent()
    {
        StartCoroutine(PageRoutine());
    }

    private IEnumerator PageRoutine()
    {        
        GameManager.SetInGameInput(false);
        CameraController.CameraShaking();
        CameraController.StartDirectCamera(cameraPos.position, 3);
        yield return YieldInstructionCache.waitForSeconds(2f);
        SequenceEvent.StartEvent(0);
        yield return YieldInstructionCache.waitForSeconds(1.5f);
        CameraController.EndDirecCamera();
        GameManager.SetInGameInput(true);
    }

}

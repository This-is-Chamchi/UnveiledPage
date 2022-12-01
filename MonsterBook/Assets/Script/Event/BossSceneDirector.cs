using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class BossSceneDirector : MonoBehaviour
{
    [Header("Stage 1")]
    [SerializeField] private Camera mainCamera;
    [SerializeField] private LayerMask turnOnCameraLayer;
    [SerializeField] private LayerMask turnOffCameraLayer;
    [SerializeField] private Hansel hansel;

    [SerializeField] private Transform leftHinge;
    [SerializeField] private Transform rightHinge;
    [SerializeField] private GameObject ground;

    [Header("Stage 2")]
    [SerializeField] private SequenceEvent start;
    [SerializeField] private Transform fixCamera;
    [SerializeField] private GameObject limitArea;


    public void LoadScene(int i)
    {
        StartCoroutine(LoadSceneRoutine(i));
    }

    private IEnumerator LoadSceneRoutine(int i)
    {
        yield return YieldInstructionCache.waitForSeconds(2f);
        SceneManager.LoadScene(i);
    }


    public void StartStage(int i)
    {
        if (i == 1) StartCoroutine(Stage1StartRoutine());
        else if (i == 2) StartCoroutine(Staga2StartRoutine());
    }

    private IEnumerator Stage1StartRoutine()
    {
        SoundManager.StopBGM(1);
        yield return YieldInstructionCache.waitForSeconds(0.2f);
        GameManager.SetInGameInput(false);
        var player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        player.ChangePatrol();
        yield return YieldInstructionCache.waitForSeconds(2f);
        //while (player.transform.position != new Vector3())
        //{

        //    yield return YieldInstructionCache.waitForFixedUpdate;
        //}
        yield return YieldInstructionCache.waitForSeconds(4f);
        var count = 0;
        while (count <= 7)
        {
            mainCamera.cullingMask = turnOnCameraLayer;
            yield return YieldInstructionCache.waitForSeconds(0.06f);
            mainCamera.cullingMask = turnOffCameraLayer;
            count++;
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
        mainCamera.cullingMask = turnOnCameraLayer;
        yield return YieldInstructionCache.waitForSeconds(1.3f);
        SoundManager.PlayBackGroundSound("1Stage_Boss_BGM");
        GameManager.SetInGameInput(true);        
        hansel.Hansel_Start();
    }

    private IEnumerator Staga2StartRoutine()
    {
        GameManager.SetInGameInput(false);
        start.StartEvent();
        yield return YieldInstructionCache.waitForSeconds(3.48f);
        GameManager.SetInGameInput(true);
        CameraController.StartDirectCamera(fixCamera.position);
        CameraController.ZoomCamera(new Vector3(0, 2.35f, -56.68f));
        SoundManager.PlayBackGroundSound("2Stage_Boss_1PageBGM");
        limitArea.SetActive(true);
    }

    public void EndStage(int i)
    {
        if (i == 1)
        {
            StartCoroutine(Stage1EndRoutine());
        }
        else if (i == 2)
        {

        }
    }

    private IEnumerator Stage1EndRoutine()
    {
        CameraController.CameraShaking(1.4f);
        GameManager.SetInGameInput(false);
        ground.SetActive(false);
        while (leftHinge.localRotation != Quaternion.Euler(0, 74f, 0))
        {            
            leftHinge.localRotation = Quaternion.Lerp(leftHinge.localRotation, Quaternion.Euler(0, 74f, 0), Time.deltaTime * 4);
            rightHinge.localRotation = Quaternion.Lerp(rightHinge.localRotation, Quaternion.Euler(0, -74f, 0), Time.deltaTime * 4);            
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
        SoundManager.StopBGM();
        GameManager.FadeEffect(true, 1);
        yield return YieldInstructionCache.waitForSeconds(6f);
        SceneManager.LoadScene(3);
    }

}

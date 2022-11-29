using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StartEvent : MonoBehaviour
{
    [SerializeField] private ScenarioData scenarioData;
    private bool isTrigger;

    private void OnTriggerEnter(Collider other)
    {
        if (!isTrigger)
        {
            GameManager.SetInGameInput(false);
            GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>().IntroProduction();
            Invoke("Talk", 4);
            isTrigger = true;
        }

    }

    public void Talk()
    {
        TalkSimulator.Instance.StartScenario(scenarioData);
    }

}
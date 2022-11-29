using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Collider))]
public class StartTalkTrigger : MonoBehaviour
{
    [SerializeField]
    private ScenarioData scenarioData;

    private void Awake()
    {
        GetComponent<Collider>().isTrigger = true;
    }

    private void OnTriggerEnter(Collider other)
    {
        TalkSimulator.Instance.StartScenario(scenarioData);        
        gameObject.SetActive(false);
    }

}

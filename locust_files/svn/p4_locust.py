import os
import logging
from locust import Locust, events, task, TaskSet
import RepoBenchmark
import RepoLocust

logger = logging.getLogger("repo_benchmark")

startdir = os.getcwd()

class P4RepoTasks(TaskSet):

    min_wait = 1000
    max_wait = 10000
    request_type = "p4"

    def __init__(self, *args, **kwargs):
        super(P4RepoTasks, self).__init__(*args, **kwargs)
        self.config = RepoBenchmark.readConfig(startdir)
        self.min_wait = self.config["general"]["min_wait"]
        self.max_wait = self.config["general"]["max_wait"]

    def on_start(self):
        name = "sync"
        count = 0
        t = RepoLocust.Timer(self.request_type)
        try:
            self.rb = RepoBenchmark.P4Benchmark(startdir, self.config)
            existed = self.rb.createWorkspace()
            if not existed:
                name = "init_sync"
            count = self.rb.syncWorkspace()
        except Exception as e:
            logger.exception(e)
            t.report_failure(name, e)
        else:
            t.report_success(name, count)

    @task(10)
    def basicFileActions(self):
        pass
        # RepoBenchmark.basicFileActions(self.rb, self.request_type)

class P4RepoTestLocust(Locust):
    """Will be imported and then run by locust"""
    task_set = P4RepoTasks
